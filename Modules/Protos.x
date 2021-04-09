
package Xisia {
    static class Protos
    {
        public static void AssignProtoTypes() {
            int OPosition = Parser.Position;

            while (Parser.Position <= Strings.Len(Parser.Source)) {
                if (Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(4, Parser.Source.length() - (Parser.Position - 1))).equals( "func")) {
                    Parser.SkipIdent();
                    Parser.SkipBlank();
                    Function.DeclareFrame(false, false, true, false);
                } else
                    if (Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(8, Parser.Source.length() - (Parser.Position - 1))).equals("property")) {
                        Parser.SkipIdent();
                        Parser.SkipBlank();
                        Function.DeclareFrame(false, false, true, true);
                    } else
                        if (Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(6, Parser.Source.length() - (Parser.Position - 1))).equals("export")) {
                            Parser.SkipIdent();
                            Parser.SkipBlank();
                            Function.DeclareFrame(true, false, true, false);
                        } else
                            if (Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(2, Parser.Source.length() - (Parser.Position - 1))) .equals( "//")) {
                                while (Parser.Source.charAt(Parser.Position - 1) != '\n') {
                                    Parser.Position++;
                                }
                            }

                Parser.Position++;

                if (Parser.Position >= Strings.Len(Parser.Source)) {
                    break;
                }
            }


            Parser.Position = OPosition;
        }
    };
};