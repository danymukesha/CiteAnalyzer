library(hexSticker)
imgurl <-
    system.file("man/figures/scholar.png", package = "CiteAnalyzer")
sticker(
    imgurl,
    package = "CiteAnalyzer",
    p_size = 12,
    s_x = 1,
    s_y = .8,
    s_width = .43,
    s_height = .8,
    p_color = "black",
    h_fill = "grey",
    h_color = "white",
    filename = "man/figures/logo.png"
)
