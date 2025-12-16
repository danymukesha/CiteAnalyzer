#' Plot Citation Impact
#'
#' Create comprehensive visualization of citation impact metrics
#'
#' @param scholar_profile ScholarProfile object
#' @param plot_type Character string specifying plot type ("summary", "timeline", "comparison")
#' @param compare_with list of additional ScholarProfile objects for comparison (optional)
#' @param radar_coord Character string: "radar" (default) or "polar" for radar plot style
#'
#' @return ggplot object
#'
#' @importFrom dplyr mutate arrange group_by summarise n
#' @importFrom tidyr pivot_longer
#' @import ggplot2
#' @export
PlotCitationImpact <- function(scholar_profile, plot_type = "summary", compare_with = NULL, radar_coord = c("radar", "polar")) {
    if (!inherits(scholar_profile, "ScholarProfile")) {
        stop("scholar_profile must be a ScholarProfile object")
    }

    if (!is.null(compare_with)) {
        if (!is.list(compare_with)) {
            stop("compare_with must be a list of ScholarProfile objects")
        }

        compare_with <- Filter(function(x) inherits(x, "ScholarProfile"), compare_with)

        if (length(compare_with) == 0) {
            warning("No valid ScholarProfile objects in compare_with, ignoring comparison")
            compare_with <- NULL
        }
    }

    radar_coord <- match.arg(radar_coord)

    plot_type <- match.arg(plot_type, c("summary", "timeline", "comparison"))

    if (plot_type == "summary") {
        # Create summary dashboard
        pubs <- scholar_profile@publications

        if (nrow(pubs) == 0) {
            stop("No publications found in scholar profile")
        }

        # Top publications by citations
        top_pubs <- pubs %>%
            arrange(desc(citedby)) %>%
            head(10) %>%
            mutate(title_short = ifelse(nchar(title) > 50,
                paste0(substr(title, 1, 47), "..."),
                title
            ))

        p <- ggplot(top_pubs, aes(x = reorder(title_short, citedby), y = citedby)) +
            geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
            geom_text(aes(label = citedby), hjust = -0.2, size = 3) +
            coord_flip() +
            expand_limits(y = max(top_pubs$citedby) * 1.1) +
            labs(
                title = sprintf("Top 10 Publications by Citations - %s", scholar_profile@name),
                subtitle = sprintf(
                    "Total Citations: %s | h-index: %s | i10-index: %s",
                    format(scholar_profile@citations_total, big.mark = ","),
                    scholar_profile@h_index,
                    scholar_profile@i10_index
                ),
                x = "Publication Title",
                y = "Number of Citations"
            ) +
            theme_minimal(base_size = 12) +
            theme(
                plot.title = element_text(size = 13, face = "bold"),
                plot.subtitle = element_text(size = 12, color = "gray50"),
                axis.text = element_text(size = 10),
                axis.title = element_text(size = 12, face = "bold")
            )

        return(p)
    } else if (plot_type == "timeline") {
        # Create citation timeline
        pubs <- scholar_profile@publications

        if (nrow(pubs) == 0) {
            stop("No publications found in scholar profile")
        }

        # Calculate yearly metrics
        yearly_data <- pubs %>%
            group_by(year) %>%
            summarise(
                publications = n(),
                total_citations = sum(citedby, na.rm = TRUE),
                avg_citations = mean(citedby, na.rm = TRUE),
                .groups = "drop"
            ) %>%
            arrange(year)

        # Create dual-axis plot
        p <- ggplot(yearly_data, aes(x = year)) +
            geom_line(aes(y = publications, color = "Publications"), size = 1.5) +
            geom_point(aes(y = publications, color = "Publications"), size = 3) +
            geom_line(aes(y = total_citations / 10, color = "Citations (\u00F710)"), size = 1.5, linetype = "dashed") +
            geom_point(aes(y = total_citations / 10, color = "Citations (\u00F710)"), size = 3) +
            scale_y_continuous(
                name = "Number of Publications",
                sec.axis = sec_axis(~ . * 10, name = "Total Citations")
            ) +
            scale_color_manual(values = c("Publications" = "steelblue", "Citations (\u00F710)" = "darkred")) +
            labs(
                title = sprintf("Publication and Citation Timeline - %s", scholar_profile@name),
                x = "Year",
                color = "Metric"
            ) +
            theme_minimal(base_size = 12) +
            theme(
                plot.title = element_text(size = 13, face = "bold"),
                axis.title.y.right = element_text(color = "darkred"),
                axis.title.y.left = element_text(color = "steelblue")
            )

        return(p)
    } else if (plot_type == "comparison" && !is.null(compare_with)) {
        # Create comparison plot
        all_profiles <- c(list(scholar_profile), compare_with)
        comparison_data <- data.frame()

        for (profile in all_profiles) {
            row <- data.frame(
                scholar = profile@name,
                h_index = profile@h_index,
                i10_index = profile@i10_index,
                total_citations = profile@citations_total,
                publications = nrow(profile@publications),
                stringsAsFactors = FALSE
            )
            comparison_data <- rbind(comparison_data, row)
        }

        # Normalize data for radar chart
        metrics <- c("h_index", "i10_index", "total_citations", "publications")
        normalized_data <- comparison_data
        for (metric in metrics) {
            max_val <- max(normalized_data[[metric]], na.rm = TRUE)
            if (max_val > 0) {
                normalized_data[[metric]] <- normalized_data[[metric]] / max_val
            }
        }

        # Reshape for radar chart
        radar_data <- normalized_data %>%
            tidyr::pivot_longer(
                cols = all_of(metrics),
                names_to = "metric",
                values_to = "value"
            )

        coord_radar <- function(theta = "x", start = -pi / 2, direction = 1) {
            theta <- match.arg(theta, c("x", "y"))
            r <- if (theta == "x") "y" else "x"
            ggproto(
                "CordRadar", CoordPolar,
                theta = theta, r = r, start = start,
                direction = sign(direction),
                is_linear = function(coord) TRUE
            )
        }

        if (radar_coord == "radar") {
            radar_data$metric <- factor(radar_data$metric, levels = metrics)
            coord_fn <- coord_radar()
            geom_poly <- geom_polygon(fill = NA, lineend = "butt", linewidth = 1.2, show.legend = FALSE)
        } else {
            coord_fn <- coord_polar()
            geom_poly <- NULL
        }

        p <- ggplot(radar_data, aes(x = metric, y = value, group = scholar, color = scholar)) +
            {
                if (!is.null(geom_poly)) geom_poly
            } +
            geom_point(size = 3) +
            geom_line(size = 1.2) +
            coord_fn +
            labs(
                title = "Scholar Metrics Comparison",
                subtitle = "Normalized metrics (0-1 scale)",
                x = "Metric",
                y = "Normalized Value"
            ) +
            scale_color_brewer(palette = "Set1") +
            theme_minimal(base_size = 12) +
            theme(
                plot.title = element_text(size = 13, face = "bold"),
                axis.text.x = element_text(angle = 0, hjust = 0.5),
                legend.position = "bottom"
            )

        return(p)
    }
}

#' Plot Collaboration Network
#'
#' Visualize collaboration network between scholars
#'
#' @param network igraph object representing collaboration network
#' @param layout_type Character string specifying layout algorithm ("fr", "kk", "lgl")
#' @param highlight_scholar Character string scholar ID to highlight (optional)
#'
#' @return ggplot object
#' @export
PlotCollaborationNetwork <- function(network, layout_type = "fr", highlight_scholar = NULL) {
    if (!inherits(network, "igraph")) {
        stop("network must be an igraph object")
    }

    if (igraph::gsize(network) == 0) {
        stop("Network has no edges to visualize")
    }

    # Choose layout algorithm
    layout_type <- match.arg(layout_type, c("fr", "kk", "lgl"))

    if (layout_type == "fr") {
        layout <- igraph::layout_with_fr(network)
    } else if (layout_type == "kk") {
        layout <- igraph::layout_with_kk(network)
    } else {
        layout <- igraph::layout_with_lgl(network)
    }

    if (nrow(layout) == 0) {
        stop("Layout returned empty result. Please check the graph structure.")
    }

    # Create edge data frame
    edge_df <- igraph::as_data_frame(network, what = "edges")
    edge_df$from_coords <- layout[match(edge_df$from, V(network)$name), ]
    edge_df$to_coords <- layout[match(edge_df$to, V(network)$name), ]

    # Create vertex data frame
    vertex_df <- data.frame(
        x = layout[, 1],
        y = layout[, 2],
        name = V(network)$name,
        papers = igraph::degree(network),
        cluster = as.factor(igraph::cluster_fast_greedy(network)$membership),
        stringsAsFactors = FALSE
    )

    # Create plot
    p <- ggplot() +
        # Edges
        geom_segment(
            data = edge_df,
            aes(
                x = from_coords[, 1], y = from_coords[, 2],
                xend = to_coords[, 1], yend = to_coords[, 2]
            ),
            color = "gray70",
            alpha = 0.6,
            size = edge_df$weight * 0.5
        ) +
        # Vertices
        geom_point(
            data = vertex_df,
            aes(x = x, y = y, size = papers, color = cluster),
            alpha = 0.9,
            shape = 21,
            stroke = 1
        ) +
        # Vertex labels
        geom_text(
            data = vertex_df,
            aes(x = x, y = y, label = name),
            hjust = 0.5, vjust = -1,
            size = 3,
            color = "black"
        ) +
        labs(
            title = "Collaboration Network",
            size = "Number of Papers",
            color = "Research Cluster"
        ) +
        scale_size_continuous(range = c(3, 12)) +
        scale_color_brewer(palette = "Set2") +
        theme_minimal(base_size = 12) +
        theme(
            plot.title = element_text(size = 13, face = "bold"),
            legend.position = "right",
            panel.grid = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            axis.title = element_blank()
        )

    # Highlight specific scholar if requested
    if (!is.null(highlight_scholar) && highlight_scholar %in% vertex_df$name) {
        highlight_data <- vertex_df[vertex_df$name == highlight_scholar, ]

        p <- p +
            geom_point(
                data = highlight_data,
                aes(x = x, y = y),
                size = 15,
                color = "red",
                alpha = 0.3,
                shape = 21
            ) +
            geom_text(
                data = highlight_data,
                aes(x = x, y = y, label = name),
                hjust = 0.5, vjust = -1,
                size = 4,
                color = "red",
                fontface = "bold"
            )
    }

    return(p)
}

#' Plot Publication Trends
#'
#' Create interactive publication trends visualization
#'
#' @param scholar_data ScholarData object or list of ScholarProfile objects
#' @param trend_type Character string ("publications", "citations", "both")
#' @param smoothing_span Numeric smoothing parameter for LOESS (0-1)
#'
#' @return ggplot object
#' @export
PlotPublicationTrends <- function(scholar_data, trend_type = "both", smoothing_span = 0.3) {
    if (inherits(scholar_data, "ScholarData")) {
        profiles <- scholar_data@profiles
    } else if (is.list(scholar_data) && all(sapply(scholar_data, inherits, "ScholarProfile"))) {
        profiles <- scholar_data
    } else {
        stop("scholar_data must be a ScholarData object or list of ScholarProfile objects")
    }

    if (length(profiles) == 0) {
        stop("No scholar profiles provided")
    }

    trend_type <- match.arg(trend_type, c("publications", "citations", "both"))

    # Collect all publication data
    all_data <- data.frame()

    for (profile in profiles) {
        pubs <- profile@publications

        if (nrow(pubs) > 0) {
            yearly_data <- pubs %>%
                group_by(year) %>%
                summarise(
                    publications = n(),
                    citations = sum(citedby, na.rm = TRUE),
                    avg_citations = mean(citedby, na.rm = TRUE),
                    scholar = profile@name,
                    scholar_id = profile@scholar_id,
                    .groups = "drop"
                )

            all_data <- rbind(all_data, yearly_data)
        }
    }

    if (nrow(all_data) == 0) {
        stop("No publication data available for plotting")
    }

    # Create plot based on trend type
    if (trend_type == "publications") {
        p <- ggplot(all_data, aes(x = year, y = publications, color = scholar)) +
            geom_line(size = 1.2) +
            geom_point(size = 3) +
            geom_smooth(se = FALSE, span = smoothing_span, method = "loess", size = 0.8) +
            labs(
                title = "Publication Trends Over Time",
                x = "Year",
                y = "Number of Publications",
                color = "Scholar"
            )
    } else if (trend_type == "citations") {
        p <- ggplot(all_data, aes(x = year, y = citations, color = scholar)) +
            geom_line(size = 1.2) +
            geom_point(size = 3) +
            geom_smooth(se = FALSE, span = smoothing_span, method = "loess", size = 0.8) +
            labs(
                title = "Citation Trends Over Time",
                x = "Year",
                y = "Total Citations per Year",
                color = "Scholar"
            )
    } else { # "both"
        # Reshape data for dual metrics
        plot_data <- tidyr::pivot_longer(all_data,
            cols = c(publications, citations),
            names_to = "metric", values_to = "value"
        )

        p <- ggplot(plot_data, aes(x = year, y = value, color = scholar, linetype = metric)) +
            geom_line(size = 1.2) +
            geom_point(size = 3, aes(shape = metric)) +
            facet_wrap(~metric, scales = "free_y") +
            labs(
                title = "Publication and Citation Trends",
                x = "Year",
                y = "Count",
                color = "Scholar",
                linetype = "Metric",
                shape = "Metric"
            ) +
            scale_linetype_manual(values = c("publications" = "solid", "citations" = "dashed")) +
            scale_shape_manual(values = c("publications" = 16, "citations" = 17))
    }

    p <- p +
        theme_minimal(base_size = 12) +
        theme(
            plot.title = element_text(size = 13, face = "bold"),
            legend.position = "bottom",
            panel.grid.minor = element_blank()
        )

    return(p)
}
