##
# Christoph Aurnhammer <aurnhammer@coli.uni-saarland.de>
# EEG plotting options for (lme)rERPs
# Including my adaption of topography plotting from craddm
##

library(data.table)
library(ggplot2)
library(gridExtra)

# compute standard error
se <- function(
    x,
    na.rm = FALSE
) {
    if (na.rm == TRUE) {
        sd(x, na.rm = TRUE) / sqrt(length(x[!is.na(x)]))
    } else {
        sd(x) / sqrt(length(x))
    }
}

# Return only the legend of an ggplot object
get_legend <- function(
    a_gplot
) {
    tmp <- ggplot_gtable(ggplot_build(a_gplot +
            theme(legend.box = "vertical",
                  legend.spacing.y = unit(0.005, "inch"))))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)
}

# For a single Electrode, plot per-grouping mean.
plot_grandavg_ci <- function(
    df,
    ttl,
    yunit = paste0("Amplitude (", "\u03BC", "Volt\u29"),
    ylims = NULL,
    modus = "Condition",
    tws = list(c(300, 500), c(600, 1000)),
    leg_labs,
    leg_vals
) {
    ###### DATA PROC
    if (modus %in% c("Quantile", "Condition")) {
        colnames(df)[c(4, 5)] <- c("V", "V_CI")
    } else if (modus == "Coefficient") {
        colnames(df)[c(3, 4)] <- c("V", "V_CI")
    } else if (modus == "t-value") {
        colnames(df)[c(3, 4, 5)] <- c("V", "V_CI", "V_sig")
        sig_dt <- df[,c("Spec", "Timestamp", "V_sig")]
        sig_dt$posit <- rep(seq(ylims[1]-2, ylims[1], length=length(unique(sig_dt$Spec))), each=length(unique(sig_dt$Timestamp)))
        sig_dt$sig <- factor(sig_dt$V_sig, levels=c("0", "1"), labels=c("insign", "sign"))
    }
    ##### PLOTTING
    # Initial plot call
    if (modus %in% c("Coefficient", "t-value")) {
        p <- ggplot(df, aes(x = Timestamp, y = V,
            color = Spec, fill = Spec)) + geom_line()
    }
    else if (modus %in% c("Condition", "Quantile")) {
        p <- ggplot(df, aes_string(x = "Timestamp", y = "V",
            color = modus, fill = modus)) + geom_line()
    }

    # For all plots
    p <- p + geom_ribbon(aes(x = Timestamp,
            ymax = V + V_CI, ymin = V - V_CI), alpha = 0.20, color = NA)
    p <- p + scale_y_reverse()
    p <- p + geom_hline(yintercept = 0, linetype = "dashed")
    p <- p + geom_vline(xintercept = 0, linetype = "dashed")
    p <- p + theme(panel.background = element_rect(fill = "#FFFFFF",
                    color = "#000000", size = 0.1, linetype = "solid"),
                panel.grid.major = element_line(size = 0.3,
                    linetype = "solid", color = "#A9A9A9"),
                panel.grid.minor = element_line(size = 0.15,
                    linetype = "solid", color = "#A9A9A9"),
            legend.position = "top")

    # Conditional modifications
    if (is.vector(ylims) == TRUE) {
        p <- p + ylim(ylims[1], ylims[2])
    }
    if (modus == "Quantile") {
        p <- p + labs(y=yunit, x = "Time (ms)", title = ttl)
        p <- p + scale_color_manual(name = "N400 Quantile",
                labels = leg_labs,
                values = leg_vals)
        p <- p + scale_fill_manual(name = "N400 Quantile",
                labels = leg_labs,
                values = leg_vals)
    } else if (modus == "Condition") {
        p <- p + labs(y=yunit, x = "Time (ms)", title = ttl)
        p <- p + scale_color_manual(name = "Condition",
                labels = leg_labs, values = leg_vals)
        p <- p + scale_fill_manual(name = "Condition",
                labels = leg_labs, values = leg_vals)
    } else if (modus == "Coefficient") {
        p <- p + labs(y="Intercept + Coefficient", x = "Time (ms)", title = ttl)
        p <- p + scale_color_manual(name = modus,
                labels = leg_labs, values = leg_vals)
        p <- p + scale_fill_manual(name = modus,
                labels = leg_labs, values = leg_vals)
    } else if (modus == "t-value") {
        p <- p + labs(y="T-value", x = "Time (ms)", title = ttl)
        p <- p + scale_color_manual(name = "Predictor",
                labels = leg_labs, values = leg_vals)
        p <- p + scale_fill_manual(name = "Predictor",
                labels = leg_labs, values = leg_vals)
        p <- p + geom_point(data=sig_dt, aes(x=Timestamp, y=posit, shape=sig), size=2) 
        p <- p + scale_shape_manual(values=c(32, 108), name="Corrected p-values", labels=c("Nonsignificant", "Significant"))
        p <- p + annotate("rect", xmin = tws[1][[1]][1], xmax = tws[1][[1]][2], ymin = ylims[1], ymax = ylims[2], alpha = .15)
        p <- p + annotate("rect", xmin = tws[2][[1]][1], xmax = tws[2][[1]][2], ymin = ylims[1], ymax = ylims[2], alpha = .15) 
    }

    p
}

# Plot nine electrode grid
plot_elec <- function(
    data,
    e,
    file = FALSE,
    title = "ERPs",
    yunit = paste0("Amplitude (", "\u03BC", "Volt\u29"),
    ylims = NULL,
    modus = "Condition",
    tws = list(c(250, 400), c(600, 1000)),
    leg_labs,
    leg_vals
) {
    if (modus %in% c("Tertile", "Quantile", "Condition")) {
        cols <- c("Spec", "Timestamp", modus)
    } else if (modus %in% c("Coefficient", "t-value")) {
        data[,"Spec"] <- as.factor(data$Spec)
        cols <- c("Spec", "Timestamp")
    }

    # Make individual plots
    plotlist <- vector(mode = "list", length = length(e))
    if (modus == "t-value") {
        for (i in 1:length(e)) {
            varforward <- c(e[i], paste0(e[i], "_CI"), paste0(e[i], "_sig"))
            plotlist[[i]] <- plot_grandavg_ci(cbind(data[, ..cols],
                            data[, ..varforward]), e[i], yunit,
                            ylims, modus, tws, leg_labs=leg_labs, leg_vals=leg_vals)
        }
    } else if (modus %in% c("Coefficient", "Tertile")) {
        for (i in 1:length(e)) {
            varforward <- c(e[i], paste0(e[i], "_CI"))
            plotlist[[i]] <- plot_grandavg_ci(cbind(data[, ..cols],
                            data[, ..varforward]), e[i], yunit = yunit,
                            ylims = ylims, modus = modus, leg_labs=leg_labs, leg_vals=leg_vals)
        }
    } else if (modus %in% c("Tertile", "Quantile", "Condition")) {
        for (i in 1:length(e)) {
            varforward <- c(e[i], paste0(e[i], "_CI"))
            plotlist[[i]] <- plot_grandavg_ci(cbind(data[, ..cols],
                            data[, ..varforward]), e[i], yunit = yunit,
                            ylims = ylims, modus = modus, leg_labs=leg_labs, leg_vals=leg_vals)
        }
    }
    # Get the legend
    legend <- get_legend(plotlist[[1]])
    # Arrange
    nl <- theme(legend.position = "none")
    gg <- arrangeGrob(arrangeGrob(
        plotlist[[1]] + nl
            + labs(x = ""),
        plotlist[[2]] + nl
            + labs(x = "", y = ""),
        plotlist[[3]] + nl
            + labs(x = "", y = ""),
        plotlist[[4]] + nl
            + labs(x = ""),
        plotlist[[5]] + nl
            + labs(x = "", y = ""),
        plotlist[[6]] + nl
            + labs(x = "", y = ""),
        plotlist[[7]] + nl,
        plotlist[[8]] + nl
            + labs(y = ""),
        plotlist[[9]] + nl
            + labs(y = ""),
        layout_matrix = matrix(1:9, ncol = 3, byrow = TRUE)), legend,
            heights = c(10, 1), top = textGrob(title))
    if (file != FALSE) {
       ggsave(file, gg, device = cairo_pdf, width = 7, height = 7)
    } else {
       gg
    }
}

# Plot topographic map
plot_topo <- function(
    data,
    file,
    tw = c(600, 1000),
    cond_man,
    cond_base,
    label = "Amplitude (μV)"
) {
    # get elec vector
    first_elec_ind <- grep("Fp1$", colnames(data))
    electrodes <- colnames(data)[c(first_elec_ind:(ncol(data) - 26))]

    # Subset data
    CI_elecs <- grep("_CI", colnames(data))
    data <- data[, !..CI_elecs]
    data <- data[, !c("Type", "Spec")]

    # melt to long format
    data_m <- melt(data, id.vars = c("Timestamp", "Condition"),
                    variable.name = "Electrode", value.name = "EEG")

    # select time and descriptors
    data_m_tw <- data_m[(Timestamp >= tw[1] & Timestamp <= tw[2]), ]

    generate_topo(data_m_tw, file, tw, cond_man, cond_base,
                amplim = 2.8, elec = electrodes,
                title = paste0(cond_man, " minus ", cond_base), label = label)
}

generate_topo <- function(
    data,
    file,
    tw,
    cond_man,
    cond_base,
    amplim,
    elec,
    title,
    label
) {
    # Average, compute difference, add topo sites
    data_agg <- data[, lapply(.SD, mean), by = list(Electrode, Condition),
                        .SDcols = c("EEG")]
    if (!grepl("t-values", file)) {
        data_diff <- compute_difference(data_agg, cond_man, cond_base, title)
    } else {
        data_diff <- data_agg[Condition == cond_man,
                              c("Condition", "Electrode", "EEG")]
    }

    # Load electrode location data
    elec_locs <- fread("../data/biosemi70elecs.loc", sep = "\t",
                    col.names = c("ElecNum", "Theta", "Radius", "Electrode"))
    elec_locs <- elec_locs[Electrode %in% elec]
    elec_locs$RadianTheta <- pi / 180 * elec_locs$Theta
    elec_locs$x <- elec_locs$Radius * sin(elec_locs$RadianTheta)
    elec_locs$y <- elec_locs$Radius * cos(elec_locs$RadianTheta)
    data_diff_locs <- merge(elec_locs, data_diff, by = "Electrode")

    # Create data frame to be used for interpolation
    # - the function needs columns labelled x, y, and z
    interprep <- data.table(x = data_diff_locs$x,
                            y = data_diff_locs$y,
                            z = data_diff_locs$EEG)

    # create the interpolation grid
    rmax <- .75  # specify a maximum boundary for the grid
    grid_res <- 67 # specify the interpolation grid resolution
    xo <- seq(min(-rmax, interprep$x), max(rmax, interprep$x),
                length = grid_res)
    yo <- seq(max(rmax, interprep$y), min(-rmax, interprep$y),
                length = grid_res)

    # TODO clean up v4_interp
    interpol <- data.table(v4_interp(interprep, xo, yo))
    interpol_m <- melt(interpol, id.vars = "x", variable.name = "y",
                       value.name = "EEG")
    interpol_m$y <- as.numeric(as.character(interpol_m$y))

    # Select data in circle
    interpol_m$incircle <- (interpol_m$x)^2 + (interpol_m$y)^2 < 0.7 ^ 2
    interpol_m <- interpol_m[interpol_m$incircle, ]

    # TODO find out why there is an NA
    interpol_m <- interpol_m[!is.na(interpol_m$EEG), ]

    ###### Prepare v4 Plot
    amplim_plusmin <- c(-amplim, amplim) # compute limits

    # Define color spectrum
    my_spectrum <- colorRampPalette(c("#00007F", "blue", "#0080ff", "white",
                                    "white", "white", "#ff6969", "red", "#a90101"))


    # Create head and nose shape
    # TODO figure out why I now need to set the *2.35
    head_shape <- circle_fun(c(0, 0), round(max(data_diff_locs$x) * 2.35, 4),
                             npoints = 100)
    nose <- data.table(x = c(-0.075, 0, .075), y = c(.495, .575, .495))

    # create a circle round the outside of the plotting area
    # to mask the jagged edges of the interpolation
    mask_ring <- circle_fun(diameter = 1.42)

    ###### Plot
    p <- ggplot(interpol_m, aes(x = x, y = y, fill = EEG))
    p <- p + geom_raster() + stat_contour(aes(z = EEG), binwidth = 0.5)
    p <- p + theme_topo()
    p <- p + labs(title = title, subtitle = paste0(tw[1], "-", tw[2], "ms"))
    p <- p + geom_path(data = mask_ring, aes(x, y, z = NULL, fill = NULL),
              colour = "white", size = 6)
    p <- p + scale_fill_gradientn(colours = my_spectrum(10),
                    limits = amplim_plusmin, guide = "colourbar",
                    oob = scales::squish, name = label)
    # Add electrode positions
    p <- p + geom_point(data = data_diff_locs, aes(x, y), size = 1)
    p <- p + geom_path(data = head_shape, aes(x, y, z = NULL, fill = NULL),
                       size = 1.5)
    p <- p + geom_path(data = nose, aes(x, y, z = NULL, fill = NULL),
                       size = 1.5)
    p <- p + coord_equal()

    ggsave(paste0(file, "_", cond_man, "_", tw[1], "-", tw[2], ".pdf"),
            p, device = cairo_pdf, width = 7, height = 7)
}

compute_difference <- function(
        data, cond_man, cond_base, name
) {
    data_diff <- data[Condition == cond_man, ]$EEG - data[Condition == cond_base, ]$EEG

    data.table(Timestamp = unique(data$Timestamp), Condition = factor(name),
             Electrode = unique(data$Electrode), EEG = data_diff)
}

circle_fun <- function(
    center = c(0, 0),
    diameter = 1,
    npoints = 100
) {
  r <- diameter / 2
  tt <- seq(0, 2 * pi, length.out = npoints)
  xx <- center[1] + r * cos(tt)
  yy <- center[2] + r * sin(tt)
  return(data.table(x = xx, y = yy))
}

v4_interp <- function(df, xo, yo, rmax = .75, gridRes = 67) {
  xo <- matrix(rep(xo, length(yo)), nrow = length(xo), ncol = length(yo))
  yo <- t(matrix(rep(yo, length(xo)), nrow = length(yo), ncol = length(xo)))
  xy <- df$x + df$y * sqrt(as.complex(-1))
  d <- matrix(rep(xy, length(xy)), nrow = length(xy), ncol = length(xy))
  d <- abs(d - t(d))
  diag(d) <- 1
  g <- (d^2) * (log(d) - 1) # Green's function.
  diag(g) <- 0
  weights <- qr.solve(g, df$z)
  xy <- t(xy)
  outmat <- matrix(nrow = gridRes,ncol = gridRes)
  for (i in 1:gridRes) {
    for (j in 1:gridRes) {
      test4 <- abs((xo[i, j] + sqrt(as.complex(-1)) * yo[i, j]) - xy)
      g <- (test4^2) * (log(test4) - 1)
      outmat[i, j] <- g %*% weights
    }
  }
  outDf <- data.table(x = xo[, 1], outmat)
  names(outDf)[1:length(yo[1, ]) + 1] <- yo[1, ]

  outDf
}

theme_topo <- function(
    base_size = 12
) {
  theme_bw(base_size = base_size) %+replace%
    theme(rect = element_blank(),
          line = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank()
    )
}

items_and_means <- function(data, Predictor) {
    data_items <- data[, lapply(.SD, mean), by = list(Item, Condition),
                    .SDcols = c(Predictor)]
    data_means <- data[, lapply(.SD, mean), by = list(Condition),
                    .SDcols = c(Predictor)]
    data_means <- aggregate(as.formula(paste0(Predictor, "~ Condition")),
                    data, FUN = mean)

    list(data_items, data_means)
}

plot_density <- function(data, data_means, ylab, xlab, predictor,
                        leg_labs, leg_vals, ylimits, xbreaks) {
    p <- ggplot(data, aes_string(x = predictor, color = "Condition",
                fill = "Condition"))
    p <- p + geom_density(alpha = 0.4) + theme_minimal()
    p <- p + ylim(ylimits)
    p <- p + geom_vline(data = data_means, aes_string(xintercept = predictor,
                color = "Condition"), linetype = "dashed") +
                scale_x_continuous(breaks = seq(1, 7))
    p <- p + scale_color_manual(labels = leg_labs, values = leg_vals)
    p <- p + scale_fill_manual(labels = leg_labs, values = leg_vals)
    p <- p + scale_x_continuous(name = xlab, breaks = xbreaks)
    p <- p + labs(y = ylab)
    p <- p + theme(legend.position = "bottom")
    p
}