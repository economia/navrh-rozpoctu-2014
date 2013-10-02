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
        newKapitola.lastValue = 0
    parentChildren.push newKapitola
    newKapitola
clearSingleChildren = (parent = output) ->
    parent.children?forEach (current, currentIndex) ->
        clearSingleChildren current
        if current.children?length == 1 and current.children.0.name == current.name
            parent.children[currentIndex] = current.children.0

computeSums = (parent = output) ->
    currentSum = 0
    lastSum = 0
    parent.children?forEach (current, currentIndex) ->
        computeSums current
        currentSum += current.value || current.currentSum
        lastSum += current.lastValue || current.lastSum
    if currentSum || lastSum
        parent.currentSum = currentSum
        parent.lastSum = lastSum




lastValues = {}
setLastValue = (value, kapitola, financni_misto, akce, rozpoctova_polozka) ->
    lastValues["#{kapitola}-#{financni_misto}-#{rozpoctova_polozka}"] ?= 0
    lastValues["#{kapitola}-#{financni_misto}-#{rozpoctova_polozka}"] += value
getLastValue = (kapitola, financni_misto, akce, rozpoctova_polozka) ->
    lastValues["#{kapitola}-#{financni_misto}-#{rozpoctova_polozka}"]
(err, data) <~ fs.readFile "#__dirname/../data/vydaje_puvodni.csv"
data .= toString!
lines = data.split "\n"
lines.forEach (line) ->
    [_,kapitola,_,financni_misto,_,zdroj,_,pvs,paragraf,akce,_,rozpoctova_polozka,castka] = line.split ";"
    return if not castka
    value = parseFloat castka.replace / /g ""
    setLastValue value, kapitola, financni_misto, akce, rozpoctova_polozka

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
    value = parseFloat castka
    vydaj = getObjectByName rozpoctova_polozka, financniMistoObject, no
        ..lastValue += value
    if not vydaj.value
        vydaj.value = switch
        | getLastValue kapitola, financni_misto, akce, rozpoctova_polozka => that
        | otherwise => value

clearSingleChildren!
computeSums!
json = JSON.stringify output#, null, "  "
fs.writeFile "#__dirname/../app/rozpocet.json", json
