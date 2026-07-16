# Rigenera dati.js, l'index.html principale e l'index.html di ogni categoria
# scansionando le sottocartelle di questa cartella. Va rilanciato ogni volta
# che si aggiunge/rimuove un file .html o una cartella-categoria.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

function JsonEscape($s) {
    return $s -replace '\\', '\\\\' -replace '"', '\"'
}

$categorie = Get-ChildItem -Path $root -Directory | Sort-Object Name

# ---------- dati.js ----------
$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("// File generato automaticamente da genera_menu.ps1 - non modificare a mano`n")
[void]$sb.Append("const DATI = {`n")
for ($i = 0; $i -lt $categorie.Count; $i++) {
    $catName = $categorie[$i].Name
    $files = Get-ChildItem -Path $categorie[$i].FullName -Filter "*.html" -File |
        Where-Object { $_.Name -ne "index.html" } | Sort-Object Name

    [void]$sb.Append("  `"$(JsonEscape $catName)`": [`n")
    for ($j = 0; $j -lt $files.Count; $j++) {
        $f = $files[$j]
        $nome = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
        $comma = if ($j -lt $files.Count - 1) { "," } else { "" }
        [void]$sb.Append("    { `"nome`": `"$(JsonEscape $nome)`", `"file`": `"$(JsonEscape $f.Name)`" }$comma`n")
    }
    $commaCat = if ($i -lt $categorie.Count - 1) { "," } else { "" }
    [void]$sb.Append("  ]$commaCat`n")
}
[void]$sb.Append("};`n")
Set-Content -Path (Join-Path $root "dati.js") -Value $sb.ToString() -Encoding UTF8

# ---------- index.html principale ----------
$rootHtml = @'
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<title>Programmini seri ma non troppo</title>
<script src="dati.js"></script>
<style>
    body {
        margin: 0;
        min-height: 100vh;
        background: url("menu_sfondo.png") no-repeat center center fixed;
        background-size: cover;
        font-family: Arial, sans-serif;
    }
    .container {
        width: 100%;
        max-width: 960px;
        margin: 0 auto;
        padding: 20px 24px;
        box-sizing: border-box;
        text-align: center;
    }
    .logo {
        width: 65px;
        height: auto;
        margin: 0 auto 10px;
        display: block;
        filter: drop-shadow(0 0 18px rgba(34,211,238,0.5));
    }
    .menu {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: 22px;
    }
    .btn-wrap {
        position: relative;
        flex: 1 1 380px;
        max-width: 420px;
        padding-bottom: 8px;
    }
    .btn {
        display: block;
        width: 100%;
        box-sizing: border-box;
        padding: 20px 22px;
        background: linear-gradient(180deg, rgba(30,41,59,0.92), rgba(21,30,44,0.92));
        border: 1px solid rgba(34,211,238,0.30);
        border-radius: 12px;
        color: #cffafe;
        font-size: 1.15em;
        font-weight: 600;
        letter-spacing: 0.2px;
        text-decoration: none;
        box-shadow: 0 1px 3px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.04);
        transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease, background-color 0.18s ease;
    }
    .btn:hover {
        border-color: rgba(34,211,238,0.6);
        background: linear-gradient(180deg, rgba(35,48,68,0.95), rgba(24,34,50,0.95));
        box-shadow: 0 8px 20px rgba(0,0,0,0.4), 0 0 0 1px rgba(34,211,238,0.25);
        transform: translateY(-2px);
    }
    .dropdown {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background-color: rgba(15, 23, 42, 0.98);
        border: 1px solid rgba(148,163,184,0.25);
        border-radius: 12px;
        box-shadow: 0 12px 28px rgba(0,0,0,0.5);
        padding: 8px;
        box-sizing: border-box;
        opacity: 0;
        pointer-events: none;
        transform: translateY(-6px);
        transition: opacity 0.18s ease, transform 0.18s ease;
        z-index: 10;
        text-align: left;
    }
    .dropdown.show {
        opacity: 1;
        pointer-events: auto;
        transform: translateY(0);
    }
    .dropdown a {
        display: block;
        padding: 8px 10px;
        color: #cffafe;
        text-decoration: none;
        font-size: 0.9em;
        font-weight: 500;
        border-radius: 8px;
    }
    .dropdown a:hover {
        background-color: rgba(34,211,238,0.14);
        color: #a5f3fc;
    }
    .dropdown .empty {
        padding: 8px 10px;
        color: #64748b;
        font-size: 0.85em;
        font-style: italic;
    }
</style>
</head>
<body>
<div class="container">
    <img class="logo" src="Logo_full.png" alt="Programmini seri ma non troppo">
    <div class="menu" id="menu"></div>
</div>
<script>
    const menu = document.getElementById("menu");
    const HOVER_DELAY = 800;

    Object.keys(DATI).sort().forEach(function (cat) {
        const wrap = document.createElement("div");
        wrap.className = "btn-wrap";

        const catPath = encodeURIComponent(cat) + "/";

        const a = document.createElement("a");
        a.className = "btn";
        a.href = catPath + "index.html";
        a.textContent = cat.replace(/_/g, " ");
        wrap.appendChild(a);

        const dropdown = document.createElement("div");
        dropdown.className = "dropdown";
        const programmi = DATI[cat];
        if (programmi.length === 0) {
            const empty = document.createElement("div");
            empty.className = "empty";
            empty.textContent = "Nessun programma";
            dropdown.appendChild(empty);
        } else {
            programmi.forEach(function (p) {
                const link = document.createElement("a");
                link.href = catPath + encodeURIComponent(p.file);
                link.textContent = p.nome;
                dropdown.appendChild(link);
            });
        }
        wrap.appendChild(dropdown);

        let hoverTimer = null;
        wrap.addEventListener("mouseenter", function () {
            hoverTimer = setTimeout(function () {
                dropdown.classList.add("show");
            }, HOVER_DELAY);
        });
        wrap.addEventListener("mouseleave", function () {
            clearTimeout(hoverTimer);
            dropdown.classList.remove("show");
        });

        menu.appendChild(wrap);
    });
</script>
</body>
</html>
'@
Set-Content -Path (Join-Path $root "index.html") -Value $rootHtml -Encoding UTF8

# ---------- index.html di ogni categoria ----------
$catTemplate = @'
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<title>__CATEGORIA__</title>
<script src="../dati.js"></script>
<style>
    body {
        margin: 0;
        min-height: 100vh;
        background: url("../menu_sfondo.png") no-repeat center center fixed;
        background-size: cover;
        font-family: Arial, sans-serif;
    }
    .container {
        width: 100%;
        max-width: 960px;
        margin: 0 auto;
        padding: 50px 24px;
        box-sizing: border-box;
        text-align: center;
    }
    h1 {
        font-size: 2.6em;
        font-weight: 800;
        margin: 0 0 40px;
        letter-spacing: 1px;
        background: linear-gradient(90deg, #0e7490, #22d3ee);
        -webkit-background-clip: text;
        background-clip: text;
        color: transparent;
        filter: drop-shadow(0 0 10px rgba(34,211,238,0.55));
    }
    .menu {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: 22px;
        margin-bottom: 36px;
    }
    .btn {
        flex: 1 1 380px;
        max-width: 420px;
        box-sizing: border-box;
        padding: 20px 22px;
        background: linear-gradient(180deg, rgba(30,41,59,0.92), rgba(21,30,44,0.92));
        border: 1px solid rgba(34,211,238,0.30);
        border-radius: 12px;
        color: #cffafe;
        font-size: 1.15em;
        font-weight: 600;
        letter-spacing: 0.2px;
        text-decoration: none;
        box-shadow: 0 1px 3px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.04);
        transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease, background-color 0.18s ease;
    }
    .btn:hover {
        border-color: rgba(34,211,238,0.6);
        background: linear-gradient(180deg, rgba(35,48,68,0.95), rgba(24,34,50,0.95));
        box-shadow: 0 8px 20px rgba(0,0,0,0.4), 0 0 0 1px rgba(34,211,238,0.25);
        transform: translateY(-2px);
    }
    .back {
        display: inline-block;
        padding: 11px 26px;
        background: rgba(30, 41, 59, 0.85);
        border: 1px solid rgba(148,163,184,0.3);
        border-radius: 10px;
        color: #cbd5e1;
        font-size: 0.95em;
        font-weight: 600;
        letter-spacing: 0.2px;
        text-decoration: none;
        box-shadow: 0 1px 3px rgba(0,0,0,0.3);
        transition: background-color 0.18s ease, border-color 0.18s ease, transform 0.18s ease;
    }
    .back:hover {
        background-color: rgba(41, 55, 78, 0.95);
        border-color: rgba(148,163,184,0.55);
        transform: translateY(-1px);
    }
    .vuoto { font-style: italic; color: #1e293b; }
</style>
</head>
<body>
<div class="container">
    <h1>__CATEGORIA_LABEL__</h1>
    <div class="menu" id="menu"></div>
    <a class="back" href="../index.html">Torna al Menu</a>
</div>
<script>
    const lista = DATI["__CATEGORIA__"] || [];
    const menu = document.getElementById("menu");
    if (lista.length === 0) {
        menu.innerHTML = "<p class=\"vuoto\">Nessun file in questa categoria.</p>";
    }
    lista.forEach(function (item) {
        const a = document.createElement("a");
        a.className = "btn";
        a.href = encodeURIComponent(item.file);
        a.textContent = item.nome;
        menu.appendChild(a);
    });
</script>
</body>
</html>
'@

foreach ($cat in $categorie) {
    $label = $cat.Name -replace '_', ' '
    $html = $catTemplate.Replace("__CATEGORIA_LABEL__", $label).Replace("__CATEGORIA__", $cat.Name)
    Set-Content -Path (Join-Path $cat.FullName "index.html") -Value $html -Encoding UTF8
}

Write-Host "Fatto. Categorie trovate: $($categorie.Count)"
foreach ($cat in $categorie) {
    $n = (Get-ChildItem -Path $cat.FullName -Filter "*.html" -File | Where-Object { $_.Name -ne "index.html" }).Count
    Write-Host "  - $($cat.Name): $n file"
}
