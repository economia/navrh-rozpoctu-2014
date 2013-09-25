require! {
    fs
}
output = []
(err, data) <~ fs.readFile "#__dirname/../data/rozpocet14Vydaje.txt"
data .= toString!
lines = data.split "\n"
lines.forEach (line) ->
    [kapitola,financni_misto,akce,rozpoctova_polozka,castka] = line.split ";"
    return if kapitola == \kapitola
    return if not financni_misto
