library(hexSticker)
imgurl <-
    system.file("man/figures/scholar - hex.png", package = "CiteAnalyzer")
sticker(
    imgurl,
    package = "CiteAnalyzer",
    p_size = 12,
    s_x = 1,
    s_y = .876,
    s_width = .554,
    s_height = .8,
    p_color = "black",
    h_fill = "white",
    h_color = "grey",
    filename = "man/figures/logo.png"
)
