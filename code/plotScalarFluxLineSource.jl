using Base: Float64
include("settings.jl")
include("SolverCSD.jl")
include("SolverMLCSD.jl")

using PyCall
using PyPlot
using DelimitedFiles
using WriteVTK

close("all")

problem = "LineSource"
nx = 201;
s = Settings(nx,nx,100,problem);
rhoMin = minimum(s.density);

if s.problem == "AirCavity"
    smapIn = readdlm("dose_ac.txt", ',', Float64)
    xRef = smapIn[:,1]
    doseRef = smapIn[:,2]
elseif s.problem == "WaterPhantomKerstin"
    smapIn = readdlm("doseStarmapWaterPhantom.txt", ',', Float64)
    xRef = smapIn[:,1]
    doseRef = smapIn[:,2]
elseif s.problem == "2D"
    doseRef = readdlm("validationData/dose_starmap_full301.txt", Float64)
    xRef = readdlm("validationData/x_starmap_nx301.txt", Float64)
    yRef = readdlm("validationData/y_starmap_ny301.txt", Float64)
elseif s.problem == "2DHighD"
    doseRef = readdlm("validationData/dose_starmap_full301_inhomogenity.txt", Float64)
    xRef = readdlm("validationData/x_starmap_nx301.txt", Float64)
    yRef = readdlm("validationData/y_starmap_ny301.txt", Float64)
else
    xRef = 0; doseRef = 1;
end

phi_dlra = readdlm("outputLineSource/scalarFluxDLRA_csd_1stcollision_Rank100_problemLineSource_nx200ny200nPN21eMax1.0rhoMin1.0.txt", Float64)
phi_Llow = readdlm("outputLineSource/scalarFlux_csd_1stcollision_problemLineSource_nx200ny200nPN21eMax1.0rhoMin1.0epsAdapt0.3L2.txt", Float64)
phi_Lhigh = readdlm("outputLineSource/scalarFlux_csd_1stcollision_problemLineSource_nx200ny200nPN21eMax1.0rhoMin1.0epsAdapt0.3L5.txt", Float64)
phi_full = readdlm("outputLineSource/scalarFlux_csd_1stcollision_problemLineSource_nx200ny200nPN21eMax1.0rhoMin1.0.txt", Float64)

fig, (ax2, ax1, ax3, ax4) = plt.subplots(2, 2,figsize=(15,15),dpi=100)
CS = ax1.pcolormesh(s.xMid[2:(end-1)],s.yMid[2:(end-1)],phi_dlra[2:(end-1),2:(end-1)],cmap="plasma")
CS = ax2.pcolormesh(s.xMid[2:(end-1)],s.yMid[2:(end-1)],phi_Llow[2:(end-1),2:(end-1)],cmap="plasma")
CS = ax3.pcolormesh(s.xMid[2:(end-1)],s.yMid[2:(end-1)],phi_Lhigh[2:(end-1),2:(end-1)],cmap="plasma")
CS = ax4.pcolormesh(s.xMid[2:(end-1)],s.yMid[2:(end-1)],phi_full[2:(end-1),2:(end-1)],cmap="plasma")
ax1.set_title("fixed rank r = $(s.r), L = 0", fontsize=20)
ax2.set_title(L"L = 1, $\vartheta$=0.3", fontsize=20)
ax3.set_title(L"L = 4, $\vartheta$=0.3", fontsize=20)
ax4.set_title(L"P$_N$", fontsize=20)
ax1.tick_params("both",labelsize=15) 
ax2.tick_params("both",labelsize=15) 
ax3.tick_params("both",labelsize=15) 
ax4.tick_params("both",labelsize=15) 
ax1.set_xlabel("x / [cm]", fontsize=15)
ax1.set_ylabel("y / [cm]", fontsize=15)
ax2.set_xlabel("x / [cm]", fontsize=15)
ax2.set_ylabel("y / [cm]", fontsize=15)
ax3.set_xlabel("x / [cm]", fontsize=15)
ax3.set_ylabel("y / [cm]", fontsize=15)
ax4.set_xlabel("x / [cm]", fontsize=15)
ax4.set_ylabel("y / [cm]", fontsize=15)
ax1.set_aspect(1)
ax2.set_aspect(1)
ax3.set_aspect(1)
ax4.set_aspect(1)
#cb = plt.colorbar(CS,fraction=0.035, pad=0.02)
#cb.ax.tick_params(labelsize=15)
tight_layout()
savefig("output/scalarFlux_compare_csd_1stcollision_DLRAM_Rank$(s.r)nx$(s.NCellsX)ny$(s.NCellsY)nPN$(s.nPN)eMax$(s.eMax)rhoMin$(rhoMin)epsAdapt$(s.epsAdapt).png")

##################### plot rank in energy #####################
L = 5;
L1 = 2;

rankInTime = readdlm("outputLineSource/rank_csd_1stcollision_problemLineSource_nx200ny200nPN21eMax1.0rhoMin1.0L2epsAdapt0.3.txt", Float64)
rankInTimeML = readdlm("outputLineSource/rank_csd_1stcollision_problemLineSource_nx200ny200nPN21eMax1.0rhoMin1.0L5epsAdapt0.3.txt", Float64)

fig = figure("rank in energy",figsize=(10, 10), dpi=100)
ax = gca()
ltype = ["b-","r--","m-","g-","y-","k-","b--","r--","m--","g--","y--","k--","b-","r-","m-","g-","y-","k-","b--","r--","m--","g--","y--","k--","b-","r-","m-","g-","y-","k-","b--","r--","m--","g--","y--","k--"]
labelvec = [L"rank $\mathbf{u}_{1}$",L"rank $\mathbf{u}_{c}$"]
for l = 1:L1
    ax.plot(rankInTime[1,1:(end-1)],rankInTime[l+1,1:(end-1)], ltype[l], linewidth=2, label=labelvec[l], alpha=1.0)
end
ax.set_xlim([0.0,s.eMax])
#ax.set_ylim([0.0,440])
ax.set_xlabel("energy [MeV]", fontsize=20);
ax.set_ylabel("rank", fontsize=20);
ax.tick_params("both",labelsize=20) 
ax.legend(loc="upper right", fontsize=20)
tight_layout()
fig.canvas.draw() # Update the figure

fig = figure("rank in energy, ML",figsize=(10, 10), dpi=100)
ax = gca()
ltype = ["b-","r--","m:","g-.","y-","k-","b--","r--","m--","g--","y--","k--","b-","r-","m-","g-","y-","k-","b--","r--","m--","g--","y--","k--","b-","r-","m-","g-","y-","k-","b--","r--","m--","g--","y--","k--"]
labelvec = [L"rank $\mathbf{u}_{1}$",L"rank $\mathbf{u}_{2}$",L"rank $\mathbf{u}_{3}$",L"rank $\mathbf{u}_{4}$",L"rank $\mathbf{u}_{c}$"]
for l = 1:L
    ax.plot(rankInTimeML[1,1:(end-1)],rankInTimeML[l+1,1:(end-1)], ltype[l], linewidth=2, label=labelvec[l], alpha=1.0)
end
ax.set_xlim([0.0,s.eMax])
#ax.set_ylim([0.0,440])
ax.set_xlabel("energy [MeV]", fontsize=20);
ax.set_ylabel("rank", fontsize=20);
ax.tick_params("both",labelsize=20) 
ax.legend(loc="upper right", fontsize=20)
tight_layout()
fig.canvas.draw() # Update the figure