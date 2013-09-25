require! {
    fs
}
output = {name: \Ropzpočet children: []}
getObjectByName = (name, parent = output) ->
    parentChildren = parent.children
    for child in parentChildren
        if child.name == name
            return child
    newKapitola = {name, children: []}
    parentChildren.push newKapitola
    newKapitola

(err, data) <~ fs.readFile "#__dirname/../data/rozpocet14Vydaje.txt"
data .= toString!
lines = data.split "\n"
# lines.length = 20
lastKapitola = null
lastKapitolaObject = null
lines.forEach (line) ->
    [kapitola,financni_misto,akce,rozpoctova_polozka,castka] = line.split ";"
    return if kapitola == \kapitola
    return if not financni_misto
    kapitolaObject = switch
        | lastKapitola == kapitola
            lastKapitolaObject
        | otherwise
            lastKapitola = kapitola
            lastKapitolaObject = getObjectByName kapitola
    financniMistoObject = getObjectByName financni_misto, kapitolaObject
    castka = parseFloat castka
    financniMistoObject.children.push {name: rozpoctova_polozka, value: castka}
json = JSON.stringify output, null, "  "
fs.writeFile "#__dirname/../app/rozpocet.json", json
