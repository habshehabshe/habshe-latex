# 4 = LuaLaTeX (PDF engine directly)
$pdf_mode = 4;
$postscript_mode = $dvi_mode = 0;

# Use non-stop mode and emit SyncTeX for editor forward/backward search
$lualatex = 'lualatex -interaction=nonstopmode -synctex=1 %O %S';

# Automatically run Biber when citation keys change (.bcf state)
$biber = 'biber %O %S';

# Everyday cleaning (-c): Auxiliaries, but KEEP the PDF and synctex.gz
$clean_ext = 'aux bbl blg fdb_latexmk fls log out toc nav snm vrb bcf run.xml tdo idx ilg ind';

# Full purge (-C): Also delete synctex data
$clean_full_ext = 'synctex.gz synctex(busy)';
