module Complexity

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Main;
import Read;

str none   = "n";
str small  = "s";
str medium = "m";
str large  = "l";

// mainComplexity(|project://smallsql0.21_src|)
str mainComplexity(loc projectLocation){
    list[loc] fileLocations = getFiles(projectLocation);
    map[str, int] CCperUnit= (none: 0, small: 0, medium: 0, large: 0);
    for (file <- fileLocations) {
        Declaration ast = createAstFromFile(file, true);
        visit(ast) {
            case \method(_,_,_,_,impl): CCperUnit[determineUnitCC(impl)] += 1;
        }
    }
    return determineRank(CCperUnit);
}

str determineUnitCC(Statement source) {
    int amount = 1;
    visit(source) {
        // conditional branches
        case \if(_,_): amount +=1;
        case \if(_,_,_): amount +=1;
        case \return(_): amount +=1;
        case \return(): amount +=1;
        case \try(_,_,_): amount +=1;
        case \try(_,_): amount +=1;
        case \catch(_,_): amount +=1;
        case \case(_): amount +=1;
        case \defaultCase(): amount +=1;
        // loops
        case \for(_,_,_,_): amount +=1;
        case \for(_,_,_): amount +=1;
        case \foreach(_,_,_): amount +=1;
        case \while(_,_): amount +=1;
        // new instances
        case \newArray(_,_,_): amount +=1;
        case \newArray(_,_): amount +=1;
        case \newObject(_,_,_,_): amount +=1;
        case \newObject(_,_,_): amount +=1;
        case \newObject(_,_): amount +=1;
        case \variable(_,_,_): amount +=1;
        case \variable(_,_): amount +=1;
    }

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

// rank | small | med  | large
//  ++  |  25%  |  0%  |  0%
//   +  |  30%  |  5%  |  0%
//   o  |  40%  | 10%  |  0%
//   -  |  50%  | 15%  |  5%
//  --  |  -    |  -   |  -
str determineRank(map[str,int] CCperUnit) {
    real totalunits = CCperUnit[large] + CCperUnit[medium] + CCperUnit[small] + CCperUnit[none] * 1.0;
    real largerisk = (CCperUnit[large] / totalunits) * 100;
    real mediumrisk = (CCperUnit[medium] / totalunits) * 100;
    real lowrisk = (CCperUnit[small] / totalunits) * 100;
    println(largerisk);
    println(mediumrisk);
    println(lowrisk);
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
