    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;

cd (address)
aa1=dir('tavg*.nc');
filename1=aa1(1,1).name;
SHF_glb_GC_T31 = get_global_SHF(filename1)
SWF_glb_GC_T31 = get_global_SWF(filename1)

cd ../PreInd_chey_contr
aa1=dir('tavg*.nc');
filename1=aa1(1,1).name;
SHF_glb_ctrl_T31 = get_global_SHF(filename1)
SWF_glb_ctrl_T31 = get_global_SWF(filename1)

cd ../../high_res/OBS_pop_all_crrt_PreIn
aa1=dir('tavg*.nc');
filename1=aa1(1,1).name;
SHF_glb_GC_f19 = get_global_SHF(filename1)
SWF_glb_GC_f19 = get_global_SWF(filename1)

cd ../PreInd_f19_g16
aa1=dir('tavg*.nc');
filename1=aa1(1,1).name;
SHF_glb_ctrl_f19 = get_global_SHF(filename1)
SWF_glb_ctrl_f19 = get_global_SWF(filename1)


