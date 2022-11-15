plot_GAMM_polar = function(model, target, var1, var2=NULL, title=NULL,
                           df_pal=NULL, subject=NULL, rep=NULL){
  # Set the conditions.
  c1 = list(var1); names(c1) = target
  if (!is.null(var2)){
    c2 = list(var2); names(c2) = target
    comp = list(c(var1, var2)); names(comp) = target
  }
  # Gathering information for the curves and significant regions.
  p1 = plot_smooth(model, view="Theta", cond=c1, rm.ranef=TRUE)
  if (!is.null(var2)){
    p2 = plot_smooth(model, view="Theta", cond=c2, rm.ranef=TRUE)
    diff = capture.output(plot_diff(model, view="Theta", comp=comp))
  }
  # Add GAMM curves.
  p = plot_ly(type='scatterpolar', mode='lines') %>%
    add_trace(theta=(p1$fv$Theta)*180/pi, r=p1$fv$fit, line=list(color="blue", dash="dash", width=2.5), name=var1) %>%
    add_trace(theta=(p1$fv$Theta)*180/pi, r=p1$fv$ul, line=list(color="blue", dash="dash", width=1), showlegend=FALSE) %>%
    add_trace(theta=(p1$fv$Theta)*180/pi, r=p1$fv$ll, line=list(color="blue", dash="dash",  width=1), showlegend=FALSE)
  if (!is.null(var2)){
    p %<>%
      add_trace(theta=(p2$fv$Theta)*180/pi, r=p2$fv$fit, line=list(color="red", width=2.5), name=var2) %>%
      add_trace(theta=(p2$fv$Theta)*180/pi, r=p2$fv$ul, line=list(color="red", dash="dot", width=1), showlegend=FALSE) %>%
      add_trace(theta=(p2$fv$Theta)*180/pi, r=p2$fv$ll, line=list(color="red", dash="dot", width=1), showlegend=FALSE)
  }
  # Add palate tracing.
  if (!is.null(df_pal) & !is.null(subject) & !is.null(rep)){
    pal = df_pal[and(df_pal$Subject == subject, df_pal$Rep == rep), ]
    p %<>%
      add_trace(theta=pal$Theta*180/pi, r=pal$R, line=list(color="black", width=2.5), name="palate")
  }
  print(p)
  # Determine the upper limit of the plot.
  if (!is.null(df_pal) & !is.null(subject) & !is.null(rep)){
    maximum = max(p1$fv$ul, pal$R) + 2
  }else if (!is.null(var2)){
    maximum = max(p1$fv$ul, p2$fv$ul) + 2
  }else{
    maximum = max(p1$fv$ul) + 2
  }
  # Scatterpolar plot.
  if (!is.null(title)){title_name = title}
  else if (!is.null(var2)){title_name = paste0("GAM smooths ", var1, " vs ", var2)}
  else{title_name = paste0("GAM smooths ", var1)}
  p %<>%
    layout(polar=list(sector=c(20,160), radialaxis=list(angle=90, range=c(0,maximum)),
                      angularaxis=list(thetaunit='radians', direction="counterclockwise", rotation=0)),
           title=title_name,
           legend=list(orientation="h", xanchor="center", x=0.5, font=list(size=18)),
           margin=list(r=50))
  # Add significant regions into the plot as shaded.
  if (!is.null(var2)){
    idx = which(str_detect(diff, "significant difference"))
    if (length(idx) > 0){
      for (n_diff in c((idx+1) : length(diff))){
        sig_diff = c(as.double(strsplit(strsplit(diff[n_diff], " ")[[1]][1], "\t")[[1]][2]), as.double(strsplit(diff[n_diff], " ")[[1]][3]))
        p %<>% add_trace(theta=seq(sig_diff[1]*180/pi, sig_diff[2]*180/pi, length.out=20), 
                         r=c(0, rep(maximum, 18), 0), line=list(color="black", width=0.5), fill="toself", fillcolor=rgb(0,0,0,max=255,alpha=25), showlegend=FALSE)
      }
    }
  }
  print(p)
}