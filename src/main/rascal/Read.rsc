module Read

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;

// Create a list of all file locations in the project
public list[loc] getFiles(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[loc] fileLocations = [f | f <- files(model.containment), isCompilationUnit(f)];
    return fileLocations;
}

// Convert a file into an array
public list[str] file2Array(loc file) {
    return readFileLines(file);
}

public list[list[str]] getProjectLines(loc projectLocation) {
    list[loc] fileLocations = getFiles(projectLocation);
    list[list[str]] files = [];
    for (location <- fileLocations) {
        files += [deleteComments(file2Array(location))];
    }

    return files;
}

// Delete the start and end of multiline comments from a line.
public tuple[bool, str] deleteMultiComments(bool inComment, str s) {
    int endLine = size(s);
    str newString = s;
    int indexStartComment = findFirst(s, "/*");
    int indexEndComment = findFirst(s, "*/");

    // Catches lines like: "comment */", "comment */ code /* comment */"
    if ((indexEndComment < indexStartComment || indexStartComment == -1)
            && indexEndComment != -1) {
        inComment = false;
        newString = newString[indexEndComment + 2..endLine];
    }

    // Catches lines like: "/* comment", "/* comment */ code /* comment"
    while (indexStartComment != -1) {
        // Catches: "code /* comment"
        if (indexEndComment == -1) {
            inComment = true;
            newString = newString[0..indexStartComment];
        }
        // Catches: "code /* comment */ code"
        else {
            inComment = false;
            newString = newString[0..indexStartComment] + newString[indexEndComment + 2..endLine];
        }
        indexStartComment = findFirst(newString, "/*");
    }

    return <inComment, newString>;
}

// Delete an inline comment from a line.
public str deleteInlineComment(str s) {
    int indexStartComment = findFirst(s, "//");

    if (indexStartComment != -1) {
        return s[0..indexStartComment];
    }

    return s;
}

public list[str] deleteComments(list[str] file) {
    // Filter all single line comments without code before the comment and empty lines.
    // i.e. "// comment" gets filtered out, but "code // comment" is kept.
    file = [s | str s <- file, /^\s*\/\/.*/ !:= s, /^\s*$/ !:= s];
    int lastArray = size(file) - 1;
    list[str] newFile = [];
    bool inComment = false;
    // bool inString = false;

    for (s <- file){
        // println("in: <s>");
        s = deleteInlineComment(s);
        // println("out: <s>");

        bool hasCommentStart = contains(s, "/*");
        bool hasCommentEnd = contains(s, "*/");
        if (inComment && !hasCommentEnd) {
            continue;
        }
        // if (inString) {
        //     newFile = newFile + s;
        //     continue;
        // }

        if (hasCommentEnd || hasCommentStart) {
            // println("in: <s>");
            <inComment, s> = deleteMultiComments(inComment, s);
            // println("out: <s>");
        }


        newFile += trim(s);
    }
    newFile = [s | str s <- newFile, /^\s*$/ !:= s];

    return newFile;
}

