module Main

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import DateTime;
import Read;
import Volume;
import Duplication;
import ComplexityUnits;

// projectLocation main(|project://smallsql0.21_src|)
int overMain(list[loc] projectlocations) {
    for(project <- projectlocations) {
        datetime startTime = now();
        main(project);
        datetime endTime = now();
        Duration i = endTime - startTime;
        println("Time spent (mm:ss.SSS): <i.minutes>:<i.seconds>.<i.milliseconds>");

    }
    return 0;
}

int main(loc projectLocation) {
    list[loc] fileLocations = getFiles(projectLocation);
    list[list[str]] projectLines = getProjectLines(projectLocation);

    tuple[str rating, int lines] volume = countLinesProject(projectLines);
    println("Determning Volume:");
    println("\tTotal number of lines: <volume.lines>");
    println("\tVolume rating: <volume.rating>");

    str duplicates = countDuplicates(projectLines, volume.lines);
    println("Determning Duplication:");
    println("\tDuplication rating: <duplicates>");

    tuple[str CC, str US] CCUS = mainComplexityUnitSize(fileLocations, volume.lines);
    // The analytics are printed in the module to use the specific calculation results.

    str analysabilityScore = calculateMaintainabilityScore([volume.rating, duplicates, CCUS.US]);
    str changeabilityScore = calculateMaintainabilityScore([CCUS.CC, duplicates]);
    str testabilityScore = calculateMaintainabilityScore([CCUS.CC, CCUS.US]);

    println("\n\t\t|\t vol \t|\t CCPU \t|\t dupes \t|\t US \t|");
    println("-------------------------------------------------------------------------------------------------");
    println("analysability \t|\t <volume.rating> \t|\t\t|\t <duplicates> \t|\t <CCUS.US> \t|\t <analysabilityScore>");
    println("changeability \t|\t\t|\t <CCUS.CC> \t|\t <duplicates> \t|\t\t|\t <changeabilityScore>");
    println("testability \t|\t\t|\t <CCUS.CC> \t|\t\t|\t <CCUS.US> \t|\t <testabilityScore>");

    return 0;
}

str calculateMaintainabilityScore(list[str] strScores) {
    int result = 0;
    for(n <- strScores) {
        switch(n) {
            case "++":  result += 1;
            case "+":   result += 1;
            case "o":   result += 0;
            case "-":   result -= 1;
            case "--":  result -= 1;
        }
    }
    // ++ score
    if (result == 4) {
        return "++";
    }
    // + score
    if (result > 0) {
        return "+";
    }
    // o score
    if (result == 0) {
        return "o";
    }
    // - score
    if (result > -4) {
        return "-";
    }
    return "--";
}
