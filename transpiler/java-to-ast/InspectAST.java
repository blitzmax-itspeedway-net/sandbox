

package com.github.javaparser;

import com.github.javaparser.ast.CompilationUnit;

class InspectAST {
    public static void main(String[] args) {
        // Parse the code you want to inspect:
        CompilationUnit cu = StaticJavaParser.parse("class X { int x; }");
        // Now comes the inspection code:
        
        // RAW
        System.out.println(cu);

        // YAML
        YamlPrinter printer = new YamlPrinter(true);
        System.out.println( printer.output(cu) );

        // XML 
        XmlPrinter printer = new XmlPrinter(true);
        System.out.println( printer.output(cu) );

        // JSON
        JSONPrinter printer = new JSONPrinter(true);
        System.out.println( printer.output(cu) );

    }
}

