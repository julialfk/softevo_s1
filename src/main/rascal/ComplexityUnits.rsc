module ComplexityUnits

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

// mainComplexity(24017, |project://smallsql0.21_src|)
tuple[str CC, str US] mainComplexity(list[loc] fileLocations, int totalLines){
    map[str, real] CCperUnit= (none: 0.0, small: 0.0, medium: 0.0, large: 0.0);
    map[str, real] USperUnit= (none: 0.0, small: 0.0, medium: 0.0, large: 0.0);
    for (file <- fileLocations) {
        Declaration ast = createAstFromFile(file, true);
        visit(ast) {
            case a:\method(_,_,_,_,impl): {percentage = getPercentage(file, a.src, totalLines);
                                            CCperUnit[determineUnitCC(impl)] += percentage;
                                            USperUnit[determinecategories(a.src)] += percentage;}
            case a:\constructor(_,_,_,impl): {percentage = getPercentage(file, a.src, totalLines);
                                                CCperUnit[determineUnitCC(impl)] += percentage;
                                                USperUnit[determinecategories(a.src)] += percentage;}
            case a:\initializer(body): {percentage = getPercentage(file, a.src, totalLines);
                                            CCperUnit[determineUnitCC(body)] += percentage;
                                            USperUnit[determinecategories(a.src)] += percentage;}
        }
    }
    // Cyclomatic Complexity stats
    println("CC: <CCperUnit>");
    println("CC: <(CCperUnit[large] + CCperUnit[medium] + CCperUnit[small] + CCperUnit[none])>");
    // UnitSize stats
    println("US: <USperUnit>");
    println("US: <(USperUnit[large] + USperUnit[medium] + USperUnit[small] + USperUnit[none])>");
    return <determineRank(CCperUnit), determineRank(USperUnit)>;
}

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

real getPercentage(loc fileloc, loc source, int totalLines) {
    list[str] file = readFileLines(fileloc);
    list[str] unit = [];
    for(n <- [(source.begin.line-1)..source.end.line]) {
        unit += file[n];
    }
    list[str] strippedUnit = deleteComments(unit);
    return ((size(strippedUnit) * 1.0) / totalLines) * 100;
}

// rank | small | med  | large
//  ++  |  25%  |  0%  |  0%
//   +  |  30%  |  5%  |  0%
//   o  |  40%  | 10%  |  0%
//   -  |  50%  | 15%  |  5%
//  --  |  -    |  -   |  -
str determineRank(map[str,real] CCperUnit) {
    real totalunits = CCperUnit[large] + CCperUnit[medium] + CCperUnit[small] + CCperUnit[none];
    real largerisk = (CCperUnit[large] / totalunits) * 100;
    real mediumrisk = (CCperUnit[medium] / totalunits) * 100;
    real lowrisk = (CCperUnit[small] / totalunits) * 100;

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
