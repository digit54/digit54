# Rigenera dati.js, l'index.html principale e l'index.html di ogni categoria
# scansionando le sottocartelle di questa cartella. Va rilanciato ogni volta
# che si aggiunge/rimuove un file .html o una cartella-categoria.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

function JsonEscape($s) {
    return $s -replace '\\', '\\\\' -replace '"', '\"'
}

$categorie = Get-ChildItem -Path $root -Directory | Where-Object { -not $_.Name.StartsWith(".") } | Sort-Object Name

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
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@500;700;800&family=Poppins:wght@500;600;700&display=swap" rel="stylesheet">
<style>
    * { box-sizing: border-box; }

    body {
        margin: 0;
        min-height: 100vh;
        font-family: 'Poppins', 'Baloo 2', Arial, sans-serif;
        background: linear-gradient(120deg, #ff9a9e, #fecfef 20%, #a1c4fd 45%, #fbc2eb 70%, #fad0c4 100%);
        background-size: 300% 300%;
        animation: gradientShift 18s ease infinite;
        overflow-x: hidden;
        position: relative;
    }

    @keyframes gradientShift {
        0%   { background-position: 0% 50%; }
        50%  { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    .blob {
        position: fixed;
        border-radius: 50%;
        filter: blur(2px);
        opacity: 0.55;
        pointer-events: none;
        z-index: 0;
        animation: float 9s ease-in-out infinite;
    }
    .blob.b1 { width: 90px;  top: 8%;  left: 6%;  font-size: 70px; animation-duration: 8s; }
    .blob.b2 { width: 70px;  top: 70%; left: 10%; font-size: 55px; animation-duration: 10s; animation-delay: 1s; }
    .blob.b3 { width: 80px;  top: 15%; left: 88%; font-size: 60px; animation-duration: 7.5s; animation-delay: 0.5s; }
    .blob.b4 { width: 70px;  top: 78%; left: 90%; font-size: 55px; animation-duration: 9.5s; animation-delay: 1.5s; }
    .blob.b5 { width: 60px;  top: 45%; left: 3%;  font-size: 45px; animation-duration: 11s; animation-delay: 2s; }
    .blob.b6 { width: 60px;  top: 40%; left: 94%; font-size: 45px; animation-duration: 8.5s; animation-delay: 0.8s; }

    @keyframes float {
        0%, 100% { transform: translateY(0) rotate(0deg); }
        50% { transform: translateY(-22px) rotate(12deg); }
    }

    .container {
        width: 100%;
        max-width: 1000px;
        margin: 0 auto;
        padding: 36px 24px 60px;
        box-sizing: border-box;
        text-align: center;
        position: relative;
        z-index: 1;
    }

    .logo {
        width: 90px;
        height: auto;
        margin: 0 auto 6px;
        display: block;
        filter: drop-shadow(0 6px 16px rgba(255, 90, 160, 0.45));
        animation: bounce 2.6s ease-in-out infinite;
    }

    @keyframes bounce {
        0%, 100% { transform: translateY(0) rotate(-3deg); }
        50% { transform: translateY(-10px) rotate(3deg); }
    }

    .title {
        font-family: 'Baloo 2', 'Poppins', sans-serif;
        font-weight: 800;
        font-size: 2em;
        margin: 4px 0 2px;
        background: linear-gradient(90deg, #ff6b6b, #a18cd1, #4facfe, #43e97b);
        -webkit-background-clip: text;
        background-clip: text;
        color: transparent;
        letter-spacing: 0.5px;
    }

    .subtitle {
        font-size: 1em;
        font-weight: 600;
        color: #5b4b8a;
        margin: 0 0 30px;
        text-shadow: 0 1px 0 rgba(255,255,255,0.6);
    }

    .menu {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: 24px;
    }

    .btn-wrap {
        position: relative;
        flex: 1 1 340px;
        max-width: 400px;
        padding-bottom: 8px;
    }

    .btn {
        display: flex;
        align-items: center;
        gap: 12px;
        width: 100%;
        box-sizing: border-box;
        padding: 20px 22px;
        border: 3px solid rgba(255,255,255,0.6);
        border-radius: 20px;
        color: #fff;
        font-family: 'Baloo 2', 'Poppins', sans-serif;
        font-size: 1.2em;
        font-weight: 700;
        letter-spacing: 0.2px;
        text-decoration: none;
        text-shadow: 0 1px 4px rgba(0,0,0,0.25);
        box-shadow: 0 8px 0 rgba(0,0,0,0.08), 0 10px 18px rgba(0,0,0,0.15);
        transition: transform 0.2s cubic-bezier(.34,1.56,.64,1), box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .btn .emoji {
        font-size: 1.5em;
        line-height: 1;
        filter: drop-shadow(0 2px 3px rgba(0,0,0,0.2));
    }
    .btn:hover {
        border-color: rgba(255,255,255,0.95);
        transform: translateY(-4px) rotate(-1deg) scale(1.03);
        box-shadow: 0 4px 0 rgba(0,0,0,0.1), 0 16px 26px rgba(0,0,0,0.22);
    }
    .btn:active {
        transform: translateY(0) scale(0.99);
    }

    .dropdown {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background-color: rgba(255,255,255,0.98);
        border: 3px solid rgba(255,255,255,0.9);
        border-radius: 18px;
        box-shadow: 0 14px 30px rgba(90,60,150,0.28);
        padding: 8px;
        box-sizing: border-box;
        opacity: 0;
        pointer-events: none;
        transform: translateY(-8px) scale(0.97);
        transition: opacity 0.2s ease, transform 0.2s ease;
        z-index: 10;
        text-align: left;
    }
    .dropdown.show {
        opacity: 1;
        pointer-events: auto;
        transform: translateY(0) scale(1);
    }
    .dropdown a {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 9px 12px;
        color: #4b3b7a;
        text-decoration: none;
        font-family: 'Poppins', sans-serif;
        font-size: 0.92em;
        font-weight: 600;
        border-radius: 10px;
    }
    .dropdown a::before {
        content: "\1f517";
        font-size: 0.85em;
        opacity: 0.7;
    }
    .dropdown a:hover {
        background-color: var(--accent-soft, rgba(161,140,209,0.18));
        color: var(--accent, #7c5cbf);
        transform: translateX(2px);
    }
    .dropdown .empty {
        padding: 9px 12px;
        color: #a9a0c4;
        font-size: 0.88em;
        font-style: italic;
    }

    .footer-note {
        margin-top: 40px;
        font-size: 0.85em;
        font-weight: 600;
        color: #6b5a99;
        opacity: 0.8;
    }
</style>
</head>
<body>
<span class="blob b1">&#127752;</span>
<span class="blob b2">&#11088;</span>
<span class="blob b3">&#127880;</span>
<span class="blob b4">&#10024;</span>
<span class="blob b5">&#127881;</span>
<span class="blob b6">&#128640;</span>

<div class="container">
    <img class="logo" src="Logo_full.png" alt="Programmini seri ma non troppo">
    <div class="title">Programmini seri ma non troppo</div>
    <div class="subtitle">&#10024; Scegli una categoria e parti alla scoperta! &#10024;</div>
    <div class="menu" id="menu"></div>
    <div class="footer-note">Fatto con &#128156; per giocare, sperimentare e perdere un po' di tempo bene</div>
</div>
<script>
    const menu = document.getElementById("menu");
    const HOVER_DELAY = 800;

    const STYLE = {
        "Convertitori Audio Video Immagini": { emoji: "🎬", c1: "#ff9a56", c2: "#ff6b6b" },
        "Farlocche":                          { emoji: "🤪", c1: "#f78ca0", c2: "#f9748f" },
        "Giochi":                             { emoji: "🎮", c1: "#a18cd1", c2: "#fbc2eb" },
        "Memoria":                            { emoji: "🧠", c1: "#43cbff", c2: "#9708cc" },
        "Passatempo":                         { emoji: "🧩", c1: "#ffd452", c2: "#ffb347" },
        "Prova":                              { emoji: "🧪", c1: "#84fab0", c2: "#8fd3f4" },
        "Scienze":                            { emoji: "🔬", c1: "#0ba360", c2: "#3cba92" },
        "Sport":                              { emoji: "🏆", c1: "#ff5858", c2: "#f857a6" },
        "Tutto_Pdf":                          { emoji: "📄", c1: "#4facfe", c2: "#00f2fe" },
        "Utility":                            { emoji: "🛠️", c1: "#38f9d7", c2: "#43e97b" }
    };
    const DEFAULT_STYLE = { emoji: "✨", c1: "#a8edea", c2: "#fed6e3" };

    Object.keys(DATI).sort().forEach(function (cat) {
        const style = STYLE[cat] || DEFAULT_STYLE;

        const wrap = document.createElement("div");
        wrap.className = "btn-wrap";

        const catPath = encodeURIComponent(cat) + "/";

        const a = document.createElement("a");
        a.className = "btn";
        a.href = catPath + "index.html";
        a.style.background = "linear-gradient(135deg, " + style.c1 + ", " + style.c2 + ")";

        const emojiSpan = document.createElement("span");
        emojiSpan.className = "emoji";
        emojiSpan.textContent = style.emoji;
        a.appendChild(emojiSpan);

        const label = document.createElement("span");
        label.textContent = cat.replace(/_/g, " ");
        a.appendChild(label);

        wrap.appendChild(a);

        const dropdown = document.createElement("div");
        dropdown.className = "dropdown";
        dropdown.style.setProperty("--accent", style.c2);
        dropdown.style.setProperty("--accent-soft", style.c2 + "2e");
        const programmi = DATI[cat];
        if (programmi.length === 0) {
            const empty = document.createElement("div");
            empty.className = "empty";
            empty.textContent = "Nessun programma qui... per ora! 🌱";
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
$styleMap = @{
    "Convertitori Audio Video Immagini" = @{ emoji = "🎬"; c1 = "#ff9a56"; c2 = "#ff6b6b" }
    "Farlocche"                          = @{ emoji = "🤪"; c1 = "#f78ca0"; c2 = "#f9748f" }
    "Giochi"                             = @{ emoji = "🎮"; c1 = "#a18cd1"; c2 = "#fbc2eb" }
    "Memoria"                            = @{ emoji = "🧠"; c1 = "#43cbff"; c2 = "#9708cc" }
    "Passatempo"                         = @{ emoji = "🧩"; c1 = "#ffd452"; c2 = "#ffb347" }
    "Prova"                              = @{ emoji = "🧪"; c1 = "#84fab0"; c2 = "#8fd3f4" }
    "Scienze"                            = @{ emoji = "🔬"; c1 = "#0ba360"; c2 = "#3cba92" }
    "Sport"                              = @{ emoji = "🏆"; c1 = "#ff5858"; c2 = "#f857a6" }
    "Tutto_Pdf"                          = @{ emoji = "📄"; c1 = "#4facfe"; c2 = "#00f2fe" }
    "Utility"                            = @{ emoji = "🛠️"; c1 = "#38f9d7"; c2 = "#43e97b" }
}
$defaultStyle = @{ emoji = "✨"; c1 = "#a8edea"; c2 = "#fed6e3" }

$catTemplate = @'
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<title>__CATEGORIA_LABEL__</title>
<script src="../dati.js"></script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@500;700;800&family=Poppins:wght@500;600;700&display=swap" rel="stylesheet">
<style>
    * { box-sizing: border-box; }

    body {
        margin: 0;
        min-height: 100vh;
        font-family: 'Poppins', 'Baloo 2', Arial, sans-serif;
        background: linear-gradient(120deg, #ff9a9e, #fecfef 20%, #a1c4fd 45%, #fbc2eb 70%, #fad0c4 100%);
        background-size: 300% 300%;
        animation: gradientShift 18s ease infinite;
        overflow-x: hidden;
        position: relative;
    }

    @keyframes gradientShift {
        0%   { background-position: 0% 50%; }
        50%  { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    .blob {
        position: fixed;
        border-radius: 50%;
        filter: blur(2px);
        opacity: 0.55;
        pointer-events: none;
        z-index: 0;
        animation: float 9s ease-in-out infinite;
    }
    .blob.b1 { top: 8%;  left: 6%;  font-size: 70px; animation-duration: 8s; }
    .blob.b2 { top: 70%; left: 10%; font-size: 55px; animation-duration: 10s; animation-delay: 1s; }
    .blob.b3 { top: 15%; left: 88%; font-size: 60px; animation-duration: 7.5s; animation-delay: 0.5s; }
    .blob.b4 { top: 78%; left: 90%; font-size: 55px; animation-duration: 9.5s; animation-delay: 1.5s; }

    @keyframes float {
        0%, 100% { transform: translateY(0) rotate(0deg); }
        50% { transform: translateY(-22px) rotate(12deg); }
    }

    .container {
        width: 100%;
        max-width: 960px;
        margin: 0 auto;
        padding: 50px 24px;
        box-sizing: border-box;
        text-align: center;
        position: relative;
        z-index: 1;
    }
    h1 {
        font-family: 'Baloo 2', 'Poppins', sans-serif;
        font-size: 2.4em;
        font-weight: 800;
        margin: 0 0 34px;
        letter-spacing: 0.5px;
        background: linear-gradient(90deg, __C1__, __C2__);
        -webkit-background-clip: text;
        background-clip: text;
        color: transparent;
    }
    h1 .emoji {
        -webkit-background-clip: initial;
        background-clip: initial;
        color: initial;
        filter: drop-shadow(0 3px 4px rgba(0,0,0,0.15));
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
        background: linear-gradient(135deg, __C1__, __C2__);
        border: 3px solid rgba(255,255,255,0.6);
        border-radius: 20px;
        color: #fff;
        font-family: 'Baloo 2', 'Poppins', sans-serif;
        font-size: 1.15em;
        font-weight: 700;
        letter-spacing: 0.2px;
        text-decoration: none;
        text-shadow: 0 1px 4px rgba(0,0,0,0.25);
        box-shadow: 0 8px 0 rgba(0,0,0,0.08), 0 10px 18px rgba(0,0,0,0.15);
        transition: transform 0.2s cubic-bezier(.34,1.56,.64,1), box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .btn:hover {
        border-color: rgba(255,255,255,0.95);
        transform: translateY(-4px) rotate(-1deg) scale(1.03);
        box-shadow: 0 4px 0 rgba(0,0,0,0.1), 0 16px 26px rgba(0,0,0,0.22);
    }
    .back {
        display: inline-block;
        padding: 11px 28px;
        background: rgba(255,255,255,0.9);
        border: 3px solid __C2__;
        border-radius: 999px;
        color: #4b3b7a;
        font-family: 'Baloo 2', 'Poppins', sans-serif;
        font-size: 0.95em;
        font-weight: 700;
        letter-spacing: 0.2px;
        text-decoration: none;
        box-shadow: 0 4px 10px rgba(90,60,150,0.2);
        transition: transform 0.18s ease, box-shadow 0.18s ease;
    }
    .back:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 16px rgba(90,60,150,0.3);
    }
    .vuoto { font-weight: 600; color: #6b5a99; font-style: italic; }
</style>
</head>
<body>
<span class="blob b1">&#127752;</span>
<span class="blob b2">&#11088;</span>
<span class="blob b3">&#10024;</span>
<span class="blob b4">&#127881;</span>

<div class="container">
    <h1><span class="emoji">__EMOJI__</span> __CATEGORIA_LABEL__</h1>
    <div class="menu" id="menu"></div>
    <a class="back" href="../index.html">&#127968; Torna al Menu</a>
</div>
<script>
    const lista = DATI["__CATEGORIA__"] || [];
    const menu = document.getElementById("menu");
    if (lista.length === 0) {
        menu.innerHTML = "<p class=\"vuoto\">Nessun programma qui... per ora! 🌱</p>";
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
    $style = $styleMap[$cat.Name]
    if (-not $style) { $style = $defaultStyle }
    $html = $catTemplate.Replace("__CATEGORIA_LABEL__", $label).Replace("__CATEGORIA__", $cat.Name).Replace("__EMOJI__", $style.emoji).Replace("__C1__", $style.c1).Replace("__C2__", $style.c2)
    Set-Content -Path (Join-Path $cat.FullName "index.html") -Value $html -Encoding UTF8
}

Write-Host "Fatto. Categorie trovate: $($categorie.Count)"
foreach ($cat in $categorie) {
    $n = (Get-ChildItem -Path $cat.FullName -Filter "*.html" -File | Where-Object { $_.Name -ne "index.html" }).Count
    Write-Host "  - $($cat.Name): $n file"
}
