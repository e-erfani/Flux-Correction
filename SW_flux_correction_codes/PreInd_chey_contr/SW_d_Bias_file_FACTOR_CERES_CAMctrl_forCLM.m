    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

cd /homes/eerfani/Bias/CERES
load('lat_fine.mat')
load('lon_fine.mat')
cd fields_NEW
load ('SW_S_d_mo_mean')

[lon_fn_msh,lat_fn_msh] = meshgrid(lon_fine,lat_fine);


%%%% ctrl CESM %%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7_*_climo.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
    gw=ncread(filename1,'gw');
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lat_msh,lon_msh] = meshgrid(latitude, longitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';
md = [15 46 74 105	135	166	196	227	258	288	319	349] ;

nn = 0 ;
for tt1=1:12%length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    SW_S_d=ncread(filename1,'FSDS'); % Downwelling solar flux at surface (W/m2)
    SW_S_d_all(:,:,nn) = SW_S_d;      
end
    
%%%%% CERES %%%%
for tt = 1:12
    tmp = double(SW_S_d_mo_mean(:,:,tt)') ;
    tmp2 = griddata(lon_fn_msh,lat_fn_msh,tmp,lon_msh,lat_msh,'natural');
    SW_S_d_mo_mean_intrp_CAMgrid(:,:,tt) = tmp2 ; 
end

%%%%%% initial method %%%%%%%
Bias_S_d = SW_S_d_all ./ SW_S_d_mo_mean_intrp_CAMgrid ;
Bias_S_d(isnan(Bias_S_d) == 1) = 1;

for t1 = 1:365
    for m = 1:11
        if ( t1 >= md(m) && t1 < md(m+1) )
            for i = 1:size(Bias_S_d,1)
            for j = 1:size(Bias_S_d,2)
                Bias_S_d_dail_mea(i,j,t1) = (t1 - md(m)) .* (Bias_S_d(i,j,m+1) - Bias_S_d(i,j,m))...
                                           ./ (md(m+1) - md(m)) + Bias_S_d(i,j,m)  ; 
                                       
            end
            end            
        end
    
    end
        if ( t1 < md(1) ) 
            for i = 1:size(Bias_S_d,1)
            for j = 1:size(Bias_S_d,2)
                Bias_S_d_dail_mea(i,j,t1) = (t1 - (-15)) .* (Bias_S_d(i,j,1) - Bias_S_d(i,j,12))...
                                           ./ (md(1) - (-15)) + Bias_S_d(i,j,12)  ; 
            end
            end
        end
        
        if ( t1 >= md(12) )
            for i = 1:size(Bias_S_d,1)
            for j = 1:size(Bias_S_d,2)
                Bias_S_d_dail_mea(i,j,t1) = (t1 - md(12)) .* (Bias_S_d(i,j,1) - Bias_S_d(i,j,12))...
                                           ./ (365+15 - md(12)) + Bias_S_d(i,j,12)  ; 
            end
            end
        end            
end

    Bias_S_d_mea = nanmean(nanmean(Bias_S_d_dail_mea,1),2) ;
    day = 1:365 ;
    figure(1)
    plot(day,permute(Bias_S_d_mea,[3 1 2]))
    Bias_S_d_month_mean = nanmean(nanmean(Bias_S_d,1),2) ;
    hold on
    plot(md,permute(Bias_S_d_month_mean,[3 1 2]),'ok')
    eval(['print -r600 -djpeg ','timeseries_CLM_init.jpg']);
 
    
%%%%% new method %%%%%%%%
SW_S_d_all_2 = SW_S_d_all ;
SW_S_d_mo_mean_intrp_CAMgrid_2 = SW_S_d_mo_mean_intrp_CAMgrid ;
for k = 1:size(SW_S_d_all,3)
    for i = 1:size(SW_S_d_all,1)
        for j = 1:size(SW_S_d_all,2)
            if (SW_S_d_all(i,j,k) <= 2)
                SW_S_d_all_2(i,j,k) = SW_S_d_mo_mean_intrp_CAMgrid(i,j,k) ;
            end
            if (SW_S_d_mo_mean_intrp_CAMgrid(i,j,k) <= 2)
                SW_S_d_mo_mean_intrp_CAMgrid_2(i,j,k) = SW_S_d_all_2(i,j,k) ;
            end            
            if (SW_S_d_mo_mean_intrp_CAMgrid_2(i,j,k) <= 2 && SW_S_d_all_2(i,j,k) <= 2)
                Bias_S_d_2(i,j,k) = 1.0000 ;
            else
                Bias_S_d_2(i,j,k) = SW_S_d_all_2(i,j,k) ./ SW_S_d_mo_mean_intrp_CAMgrid_2(i,j,k) ;                
            end            
        end
    end
end

Bias_S_d_2(isnan(Bias_S_d_2) == 1) = 1;



for t1 = 1:365
    for m = 1:11
        if ( t1 >= md(m) && t1 < md(m+1) )
            for i = 1:size(Bias_S_d_2,1)
            for j = 1:size(Bias_S_d_2,2)
                Bias_S_d_2_dail_mea(i,j,t1) = (t1 - md(m)) .* (Bias_S_d_2(i,j,m+1) - Bias_S_d_2(i,j,m))...
                                           ./ (md(m+1) - md(m)) + Bias_S_d_2(i,j,m)  ; 
                                       
            end
            end            
        end
    
    end
        if ( t1 < md(1) ) 
            for i = 1:size(Bias_S_d_2,1)
            for j = 1:size(Bias_S_d_2,2)
                Bias_S_d_2_dail_mea(i,j,t1) = (t1 - (-15)) .* (Bias_S_d_2(i,j,1) - Bias_S_d_2(i,j,12))...
                                           ./ (md(1) - (-15)) + Bias_S_d_2(i,j,12)  ; 
            end
            end
        end
        
        if ( t1 >= md(12) )
            for i = 1:size(Bias_S_d_2,1)
            for j = 1:size(Bias_S_d_2,2)
                Bias_S_d_2_dail_mea(i,j,t1) = (t1 - md(12)) .* (Bias_S_d_2(i,j,1) - Bias_S_d_2(i,j,12))...
                                           ./ (365+15 - md(12)) + Bias_S_d_2(i,j,12)  ; 
            end
            end
        end            
end

    Bias_S_d_2_mea = nanmean(nanmean(Bias_S_d_2_dail_mea,1),2) ;
    day = 1:365 ;
    figure(2)
    plot(day,permute(Bias_S_d_2_mea,[3 1 2]))
    Bias_S_d_2_month_mean = nanmean(nanmean(Bias_S_d_2,1),2) ;
    hold on
    plot(md,permute(Bias_S_d_2_month_mean,[3 1 2]),'ok')
    eval(['print -r600 -djpeg ','timeseries_CLM_new.jpg']);

    %dbstop

    Bias_S_d_2_dail_mea(isnan(Bias_S_d_2_dail_mea)==1) = 1.0 ;
 %   Bias_S_d_2_dail_mea(Bias_S_d_2_dail_mea==0) = 1.0 ;
 %   Bias_S_d_2_dail_mea(Bias_S_d_2_dail_mea < 0.1) = 0.1 ;
 %   Bias_S_d_2_dail_mea(Bias_S_d_2_dail_mea > 2.0) = 0.1 ;

%%%%%%%%%%
SST_T31  = double(nanmean(Bias_S_d_2_dail_mea,3)) ;
        fig_name = strcat('SW_S_d_FACTOR_annual_CAMctrl_CERES_FILE_forCLM');%,num2str(tt));
        fig_dum = figure(100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
    m_proj('miller','long',[0 358],'lat',[-70 70])       
    [C, h] =  m_contourf(lon_msh, lat_msh, SST_T31,32);
    set(h,'LineColor','none')
    m_coast('linewidth',2,'color','black');
    Title_1 = 'Factor, CAM(ctrl) / CERES, Downward SW Flux at Surface, Annual Mean';    
    title(Title_1,'fontsize',20,'fontweight','bold');
    colormap(brewermap(32,'*RdBu'))
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',16);
    caxis([0.6, 1.401])
h = colorbar ; %('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
set(gca,'Fontsize',16)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)

      
%%%%
SW_S_d_CERES_intrp = nanmean(SW_S_d_mo_mean_intrp_CAMgrid,3) ;
SW_S_d_CERES_intrp_glb_mean = nansum(nansum(GW .* SW_S_d_CERES_intrp,1),2) ./ nansum(nansum(GW,1),2)

SW_S_d_ctrlCAM_month = nanmean(SW_S_d_all,3) ;
SW_S_d_ctrlCAM_month_mean = nansum(nansum(GW .* SW_S_d_ctrlCAM_month,1),2) ./ nansum(nansum(GW,1),2)

Bias_SW_S_d_mean = nanmean(SW_S_d_all - SW_S_d_mo_mean_intrp_CAMgrid,3) ;
Bias_SW_S_d_mean_ave = nansum(nansum(GW .* Bias_SW_S_d_mean,1),2) ./ nansum(nansum(GW,1),2)

%%%%%
SST_T31  = double(nanmean(SW_S_d_all - SW_S_d_mo_mean_intrp_CAMgrid,3)) ;
        fig_name = strcat('SW_S_d_bias_annual_CAMctrl_CERES_FILE_forCLM');%,num2str(tt));
        fig_dum = figure(144);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
    m_proj('miller','long',[0 358],'lat',[-70 70])
    [C, h] =  m_contourf(lon_msh, lat_msh, SST_T31,20);
    set(h,'LineColor','none')
    m_coast('linewidth',2,'color','black');
    Title_1 = 'Bias, CAM(ctrl) - CERES, Downward SW Flux at Surface, Annual Mean';    
    title(Title_1,'fontsize',20,'fontweight','bold');
    colormap(brewermap(20,'*RdBu'))
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',16);
    caxis([-40, 40])    
h = colorbar ;
set(gca,'Fontsize',16)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)

      
%%%%%
dbstop   

 nccreate('Factor_SW_S_d_daily_CAMctrl_CERES.nc','Factor_S_d_daily','Dimensions',{'lon',96,'lat',48,'day',365},'Format','classic');
 nccreate('Factor_SW_S_d_daily_CAMctrl_CERES.nc','lat','Dimensions',{'lon',96,'lat',48},'Format','classic');
 nccreate('Factor_SW_S_d_daily_CAMctrl_CERES.nc','lon','Dimensions',{'lon',96,'lat',48},'Format','classic'); 
 ncwrite('Factor_SW_S_d_daily_CAMctrl_CERES.nc','Factor_S_d_daily',Bias_S_d_2_dail_mea);
 ncwrite('Factor_SW_S_d_daily_CAMctrl_CERES.nc','lat',lat_msh);
 ncwrite('Factor_SW_S_d_daily_CAMctrl_CERES.nc','lon',lon_msh);
    
cd CLM_Factor_monthly
for tt = 1:size(Bias_S_d_2,3)
    %%%%%%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = double(Bias_S_d_2(:,:,tt)) ;
 
        fig_name = strcat('SW_S_d_Factor_FILE_CAMctrl_CERES_forCLM',num2str(tt));
        fig_dum = figure(100+tt);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
    m_proj('miller','long',[0 358],'lat',[-70 70])
    [C, h] =  m_contourf(lon_msh, lat_msh, SST_T31,32);
    set(h,'LineColor','none')
    m_coast('linewidth',2,'color','black');
    Title_1 = strcat('Factor, CAM(ctrl) / CERES, Downward SW Flux at Surface, ', month(tt));
    title(Title_1,'fontsize',20,'fontweight','bold');
    colormap(brewermap(32,'*RdBu'))
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',16);
    caxis([0.6, 1.401])
    h = colorbar ;
set(gca,'Fontsize',16)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)

 
end

cd ..

Test_SW = ncread('Factor_SW_S_d_daily_CAMctrl_CERES.nc','Factor_S_d_daily') ;
Test_lat = ncread('Factor_SW_S_d_daily_CAMctrl_CERES.nc','lat') ;
Test_lon = ncread('Factor_SW_S_d_daily_CAMctrl_CERES.nc','lon') ;

clear SST_T31
SST_T31(:,:,1)  = double(nanmean(Test_SW,3)) ;

        fig_name = strcat('SW_S_d_FACTOR_annual_fromFILE_CAMctrl_CERES_forCLM');%,num2str(tt));
        fig_dum = figure(240);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
    m_proj('miller','long',[0 358],'lat',[-70 70])
    [C, h] =  m_contourf(Test_lon, Test_lat, SST_T31,32);
    set(h,'LineColor','none')
    m_coast('linewidth',2,'color','black');
    Title_1 = 'Factor, CAM(ctrl) / CERES, Downward SW Flux at Surface, Annual Mean';
    title(Title_1,'fontsize',20,'fontweight','bold');
    colormap(brewermap(32,'*RdBu'))
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',16);
    caxis([0.6, 1.401])
h = colorbar ; %('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
set(gca,'Fontsize',16)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)

