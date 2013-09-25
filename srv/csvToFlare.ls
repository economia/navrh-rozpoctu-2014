require! {
    fs
}
output = {name: \Ropzpočet children: []}
getObjectByName = (name, parent = output, createChildren = yes) ->
    parentChildren = parent.children
    for child in parentChildren
        if child.name == name
            return child
    newKapitola = {name}
    if createChildren
        newKapitola.children = []
    else
        newKapitola.value = 0
    parentChildren.push newKapitola
    newKapitola
clearSingleChildren = (parent = output) ->
    parent.children?forEach (current, currentIndex) ->
        clearSingleChildren current
        if current.children?length == 1 and current.children.0.name == current.name
            parent.children[currentIndex] = current.children.0

(err, data) <~ fs.readFile "#__dirname/../data/rozpocet14Vydaje.txt"
data .= toString!
lines = data.split "\n"
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
    vydaj = getObjectByName rozpoctova_polozka, financniMistoObject, no
        ..value += parseFloat castka

clearSingleChildren!
json = JSON.stringify output, null, "  "
fs.writeFile "#__dirname/../app/rozpocet.json", json
