plot_GAMM_polar_multi = function(model, target, title=NULL,
                                 df_pal=NULL, subject=NULL, rep=NULL, ...){
  vars = list(...)
  if (length(vars) == 0){
    vars = model$xlevels[[target]]
  }
  
  pl = plot_ly(type='scatterpolar', mode='lines')
  maxs = c()
  for (var in vars){
    # Set the conditions.
    c = list(var); names(c) = target
    # Gathering information for the curves.
    p = plot_smooth(model, view="Theta", cond=c, rm.ranef=TRUE)
    pl %<>%
      add_trace(theta=(p$fv$Theta)*180/pi, r=p$fv$fit, line=list(width=2.5), name=var)
    maxs %<>% c(p$fv$fit)
  }
  # Add palate tracing.
  if (!is.null(df_pal) & !is.null(subject) & !is.null(rep)){
    pal = df_pal[and(df_pal$Subject == subject, df_pal$Rep == rep), ]
    pl %<>%
      add_trace(theta=pal$Theta*180/pi, r=pal$R, line=list(color="black", width=2.5), name="palate")
  }
  
  if (!is.null(title)){title_name = title}
  else {title_name = paste0("GAM smooths for ", target)}
  # Determine the upper limit of the plot.
  if (!is.null(df_pal) & !is.null(subject) & !is.null(rep)){
    maximum = max(c(maxs, pal$R)) + 2
  }else{
    maximum = max(maxs) + 2
  }
  
  pl %<>%
    layout(polar=list(sector=c(20,160), radialaxis=list(angle=90, range=c(0,maximum)),
                      angularaxis=list(thetaunit='radians', direction="counterclockwise", rotation=0)),
           title=title_name,
           legend=list(orientation="h", xanchor="center", x=0.5, font=list(size=18)),
           margin=list(r=50))
  print(pl)
}