module UnitSize

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Main;
import Read;

// globals
str none   = "n";
str small  = "s";
str medium = "m";
str large  = "l";

// mainUnitSize(|project://smallsql0.21_src|)
str mainUnitSize(loc projectLocation){
    int totalmethods = 0;
    map[str,int] categories = (none: 0, small: 0, medium: 0, large: 0);
    list[loc] fileLocations = getFiles(projectLocation);
    for (file <- fileLocations) {
        Declaration ast = createAstFromFile(file, true);
        visit(ast) {
            case a:\method(_,_,_,_,_): {totalmethods += 1; risk = determinecategories(a.src); categories[risk] = categories[risk] + 1;}
        }
    }
    return determinerank(totalmethods, categories);
}

str determinecategories(loc source) {
    int functionLength = source.end.line - (source.begin.line-1);
    if (functionLength >= 0 && functionLength < 10) {
        return none;
    }
    if (functionLength >= 10 && functionLength < 25) {
        return small;
    }
    if (functionLength >= 25 && functionLength < 50) {
        return medium;
    }
    return large;
}

// rank | small | med  | large
//  ++  |  25%  |  0%  |  0%
//   +  |  30%  |  5%  |  0%
//   o  |  40%  | 10%  |  0%
//   -  |  50%  | 15%  |  5%
//  --  |  -    |  -   |  -
str determinerank(int methods, map[str,int] categories) {
    real largerisk = (categories[large] / (methods * 1.0)) * 100;
    real mediumrisk = (categories[medium] / (methods * 1.0)) * 100;
    real lowrisk = (categories[small] / (methods * 1.0)) * 100;
    // high risk
    if (largerisk > 5 || mediumrisk > 15 || lowrisk > 50) {
        return "--";
    }
    if (largerisk > 0) {
        return "-";
    }
    // med risk
    if (mediumrisk > 0) {
        if (mediumrisk >= 5) {
            return "o";
        }
        if (mediumrisk >= 10) {
            return "-";
        }
        return "+";
    }
    // low risk
    if (lowrisk >= 40) {
        return "-";
    }
    if (lowrisk >= 30) {
        return "0";
    }
    if (lowrisk >= 25) {
        return "+";
    }
    return "++";
}