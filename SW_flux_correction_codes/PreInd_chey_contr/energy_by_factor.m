    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

cd /homes/eerfani/Bias
cd CERES
load('lat_fine.mat')
load('lon_fine.mat')
cd fields_NEW
load ('SW_S_d_mo_mean')
[lon_fn_msh,lat_fn_msh] = meshgrid(lon_fine,lat_fine);

%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7_*_climo.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  gw=ncread(filename1,'gw'); % surface net Shortwave Radiation (W/m2)
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lon_msh,lat_msh] = meshgrid(longitude,latitude);

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
    
%%%%%

for tt = 1:12
    tmp = double(SW_S_d_mo_mean(:,:,tt)') ;
    tmp2 = griddata(lon_fn_msh,lat_fn_msh,tmp,lon_msh,lat_msh,'natural');
    SW_S_d_mo_mean_intrp_CAMgrid(:,:,tt) = tmp2' ; 
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
%dbstop

    Bias_S_d_2_dail_mea(isnan(Bias_S_d_2_dail_mea)==1) = 1.0 ;
 %   Bias_S_d_2_dail_mea(Bias_S_d_2_dail_mea==0) = 1.0 ;
 %   Bias_S_d_2_dail_mea(Bias_S_d_2_dail_mea < 0.1) = 0.1 ;
 %   Bias_S_d_2_dail_mea(Bias_S_d_2_dail_mea > 2.0) = 0.1 ;

%%%%%%%%%%
scale = double(nanmean(SW_S_d_all,3)) - double(nanmean(SW_S_d_all,3)) ./ double(nanmean(Bias_S_d_2_dail_mea,3));
  cellsize = 0.5; 
SST_T31(:,:,1)  =  scale;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('energy_by_scale_factor');%,num2str(tt));
        fig_dum = figure(100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = 'FSDS - (FSDS / Scale Factor), W/m2';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
      

scale_glb_ave = nansum(nansum(GW .* scale,1),2) ./ nansum(nansum(GW,1),2)
