module ComplexityUnits

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import List;
import Set;
import String;
import Main;
import Read;

str none   = "n";
str small  = "s";
str medium = "m";
str large  = "l";
real decimals = 0.01;

// This function takes the filelocations and creates an AST per file
// it continues by visiting each node in each AST identifying units
// in Java units are methods, constructors and initializers.
// We start by determining the percentage of the unit against the entire project.
// For Cyclomatic Complexity (CC) the impl or body is passed to another function
// to determine the risk category for that specific unit. For Unit Size (US) the
// source location (a.src) is used to determine the risk category.
// The determined percentage of the unit is added to its respective risk category
// in the respective list (CC or US). This results in a list of a percentage per risk category.
// These lists are then passed to a function to determine the risk rating of the entire project.
// Resulting in a rating based on a five star scale for each CC and US.
tuple[str CC, str US] mainComplexityUnitSize(list[loc] fileLocations, int totalLines){
    map[str, real] CCperUnit= (none: 0.0, small: 0.0, medium: 0.0, large: 0.0);
    map[str, real] USperUnit= (none: 0.0, small: 0.0, medium: 0.0, large: 0.0);
    for (file <- fileLocations) {
        Declaration ast = createAstFromFile(file, true);
        visit(ast) {
            case a:\method(_,_,_,_,impl): {percentage = getPercentage(file, a.src, totalLines);
                                            CCperUnit[determineUnitCC(impl)] += percentage;
                                            USperUnit[determineUnitSize(a.src)] += percentage;}
            case a:\constructor(_,_,_,impl): {percentage = getPercentage(file, a.src, totalLines);
                                                CCperUnit[determineUnitCC(impl)] += percentage;
                                                USperUnit[determineUnitSize(a.src)] += percentage;}
            case a:\initializer(body): {percentage = getPercentage(file, a.src, totalLines);
                                            CCperUnit[determineUnitCC(body)] += percentage;
                                            USperUnit[determineUnitSize(a.src)] += percentage;}
        }
    }
    return <determineRiskRatingCC(CCperUnit), determineRiskRatingUS(USperUnit)>;
}

// This function determines the amount of complexity per unit
// This is done by visiting each node in the unit and match them to
// the control flow elements used are dicated by the oracle documentation
str determineUnitCC(Statement impl) {
    int amount = 1;
    visit(impl) {
        // conditional branches
        case \if(_,_): amount +=1;
        case \if(_,_,_): amount +=1;
        case \try(_,_,_): amount +=2;
        case \try(_,_): amount +=1;
        case \catch(_,_): amount +=1;
        case \case(_): amount +=1;
        case \conditional(_,_,_): amount +=1;
        // branching statements
        case \break(): amount +=1;
        case \break(_): amount +=1;
        case \continue(): amount +=1;
        case \continue(_): amount +=1;
        case \return(): amount +=1;
        case \return(_): amount +=1;
        // loops
        case \for(_,_,_,_): amount +=1;
        case \for(_,_,_): amount +=1;
        case \foreach(_,_,_): amount +=1;
        case \do(_,_): amount +=1;
        case \while(_,_): amount +=1;
        // infix
        case \infix(_,"&&",_): amount +=1;
        case \infix(_,"||",_): amount +=1;
    }

    // determining risk category based on the thresholds
    if (amount >= 0 && amount < 10) {
        return none;
    }
    if (amount >= 10 && amount < 25) {
        return small;
    }
    if (amount >= 25 && amount < 50) {
        return medium;
    }
    return large;
}

// determine the size of a unit according to the derived thresholds
// The derivation is explained in the accompanied report.
str determineUnitSize(loc source) {
    int functionLength = source.end.line - (source.begin.line-1);
    if (functionLength >= 0 && functionLength < 24) {
        return none;
    }
    if (functionLength >= 24 && functionLength < 36) {
        return small;
    }
    if (functionLength >= 36 && functionLength < 63) {
        return medium;
    }
    return large;
}

// helper function to determine the percentages of the stripped unit against the determined volume
real getPercentage(loc fileloc, loc source, int totalLines) {
    list[str] file = readFileLines(fileloc);
    list[str] unit = [];
    for(n <- [(source.begin.line-1)..source.end.line]) {
        unit += file[n];
    }
    list[str] strippedUnit = deleteComments(unit);
    return ((size(strippedUnit) * 1.0) / totalLines) * 100;
}

// Determine the risk rating of the Cyclomatic complexity for the entire project
// This is done by calculating the percentage of the unit LOC against the total units
// Resulting in the percentage of risk per category over the total amount of units
// i.e. where all units are 100% of the risk, each categorized unit has a % of that total amount of risk.
str determineRiskRatingCC(map[str,real] CCperUnit) {
    real totalunits = CCperUnit[large] + CCperUnit[medium] + CCperUnit[small] + CCperUnit[none];
    num norisk = round((CCperUnit[none] / totalunits) * 100, decimals);
    num smallrisk = round((CCperUnit[small] / totalunits) * 100, decimals);
    num mediumrisk = round((CCperUnit[medium] / totalunits) * 100, decimals);
    num largerisk = round((CCperUnit[large] / totalunits) * 100, decimals);
    println("Determining risk rating for Cyclomatic Complexity:");
    // Since rascal's switch cases can't match ranges, we are forced to use if else statements
    if (largerisk > 0) {
        if (largerisk > 5 || mediumrisk > 15 || smallrisk > 50) {
            if(largerisk > 5) {
                println("\t\'--\' rank determined, large risk threshold violation. \tlarge risk: <largerisk>% \> 5%");
            }
            if(mediumrisk > 15) {
                println("\t\'--\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \> 15%");
            }
            if(smallrisk > 50) {
                println("\t\'--\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \> 50%");
            }
            return "--";
        }
        println("\t\'-\' rank determined, large risk threshold violation. \tlarge risk: <largerisk>% \> 0%");
        return "-";
    }
    // med risk
    if (mediumrisk > 0) {
        if (mediumrisk >= 5) {
            if (mediumrisk >= 10) {
                println("\t\'-\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \>= 10%");
                return "-";
            }
            println("\t\'o\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \>= 5%");
            return "o";
        }
        println("\t\'+\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \> 0%");
        return "+";
    }
    // low risk
    if (smallrisk >= 25) {
        if (smallrisk >= 30) {
            if (smallrisk >= 40) {
                println("\t\'-\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \>= 40%");
                return "-";
            }
            println("\t\'o\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \>= 30%");
            return "o";
        }
        println("\t\'+\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \>= 25%");
        return "+";
    }
    println("\t\'++\' rank determined, no thresholds have been violated.");
    return "++";
}

// Unit Size Thresholds
// rank | small | med  | large
//  ++  |  15%  | 10%  |  0%
//   +  |  20%  | 15%  |  5%
//   o  |  25%  | 20%  |  10%
//   -  |  30%  | 25%  |  15%
//  --  |  -    |  -   |  -
str determineRiskRatingUS(map[str,real] USperUnit) {
    real totalunits = USperUnit[large] + USperUnit[medium] + USperUnit[small] + USperUnit[none];
    num norisk = round((USperUnit[none] / totalunits) * 100, decimals);
    num smallrisk = round((USperUnit[small] / totalunits) * 100, decimals);
    num mediumrisk = round((USperUnit[medium] / totalunits) * 100, decimals);
    num largerisk = round((USperUnit[large] / totalunits) * 100, decimals);
    println("Determining risk rating for Unit Size:");

    // Since rascal's switch cases can't match ranges, we are forced to use if else statements
    // catch large risk
    if (largerisk > 15 || mediumrisk > 25 || smallrisk > 30) {
            if(largerisk > 5) {
                println("\t\'--\' rank determined, large risk threshold violation. \tlarge risk: <largerisk>% \> 15%");
            }
            if(mediumrisk > 15) {
                println("\t\'--\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \> 25%");
            }
            if(smallrisk > 50) {
                println("\t\'--\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \> 30%");
            }
        return "--";
    }

    if (largerisk > 0) {
        if (largerisk > 5) {
            if (largerisk > 10) {
                println("\t\'-\' rank determined, large risk threshold violation. \tlarge risk: <largerisk>% \> 10%");
                return "-";
            }
            println("\t\'o\' rank determined, large risk threshold violation. \tlarge risk: <largerisk>% \> 5%");
            return "o";
        }
        println("\t\'+\' rank determined, large risk threshold violation. \tlarge risk: <largerisk>% \> 0%");
        return "+";
    }
    // catch med risk
    if (mediumrisk > 10) {
        if (mediumrisk >= 15) {
            if (mediumrisk >= 20) {
                println("\t\'-\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \> 20%");
                return "-";
            }
            println("\t\'o\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \> 15%");
            return "o";
        }
        println("\t\'+\' rank determined, medium risk threshold violation. \tmedium risk: <mediumrisk>% \> 10%");
        return "+";
    }
    // catch low risk
    if (smallrisk >= 10) {
        if (smallrisk >= 15) {
            if (smallrisk >= 20) {
                println("\t\'-\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \> 20%");
                return "-";
            }
            println("\t\'o\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \> 15%");
            return "o";
        }
        println("\t\'+\' rank determined, small risk threshold violation. \tsmall risk: <smallrisk>% \>= 10%");
        return "+";
    }
    println("\t\'++\' rank determined, no thresholds have been violated.");
    return "++";
}