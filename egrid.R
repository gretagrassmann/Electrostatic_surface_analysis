library(tidyverse)
library(rgrids)
library(tools)

args = commandArgs(trailingOnly=TRUE)

surf <- read.csv(args[1], header = F, sep = "", col.names = LETTERS[1:11] )

clear_dms_file <- function(surf) {

  surf_final <- surf %>% 
    mutate(across(where(is.character), str_trim)) %>% 
    mutate(B = gsub("[[:punct:]]", "", as.character(B))) %>% 
    filter(str_sub(G, 1, 1) == "S") %>% 
    unite(Res, c(1,2)) %>% 
    select(c(1, 3, 4, 5, 8, 9, 10)) %>% 
    set_names(c("Res", "x", "y", "z", "Nx", "Ny", "Nz"))

  return(surf_final)
}

clear_surf <- clear_dms_file(surf)

gridCell_char <- system(paste("grep 'object 1' ", args[2], " | awk '{print $(NF-2), $(NF-1), $NF}' ", sep = ""), intern = TRUE)
gridCell <- as.numeric(unlist(strsplit(gridCell_char, " ")))

origin_char <- system(paste("grep 'origin' ", args[2], " | awk '{print $(NF-2), $(NF-1), $NF}' ", sep = ""), intern = TRUE)
origin <- as.numeric(unlist(strsplit(origin_char, " ")))

delta_char <- system(paste("grep 'delta' ", args[2], " | awk '{print $(NF-2), $(NF-1), $NF}' ", sep = ""), intern = TRUE)
delta <- as.numeric(unlist(strsplit(delta_char, " ")))[c(1, 5, 9)]

potential_char <- system(paste("egrep  '^[e0-9\\.+\\-]+' ", args[2], sep = ""), intern = TRUE)
potential <- as.numeric(unlist(strsplit(potential_char, " ")))

surfaceGrid <- makeGrid3d(
  xmin = origin[1], ymin = origin[2], zmin = origin[3],
  xmax = origin[1] + gridCell[1] * delta[1], ymax = origin[2] + gridCell[2] * delta[2], zmax = origin[3] + gridCell[3] * delta[3],
  xcell = gridCell[1], ycell = gridCell[2], zcell = gridCell[3], by = "v"
)

ndxCell <- getCell(surfaceGrid, clear_surf[, 2:4])
surf_potential <- potential[ndxCell]


surf_el <- clear_surf %>% 
  mutate(el = surf_potential)
protein=gsub('.{2}$','',file_path_sans_ext(basename(args[1])))
print(protein)
write_csv(surf_el, paste(args[3], paste0("surf_el_",protein,".csv", sep = "")))
