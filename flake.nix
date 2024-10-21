{
    inputs =
        {
            environment-variable-lib.url = "github:viktordanek/environment-variable" ;
            flake-utils.url = "github:numtide/flake-utils" ;
            has-standard-input-lib.url = "github:viktordanek/has-standard-input" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            strip-lib.url = "github:viktordanek/strip" ;
            temporary-lib.url = "github:viktordanek/temporary" ;
        } ;
    outputs =
        { environment-variable-lib , flake-utils , has-standard-input-lib , nixpkgs , self , strip-lib , temporary-lib } :
            let
                fun =
                    system :
                        let
                            lib =
                                seed : path : name : value :
                                    let
                                        type = builtins.typeOf value ;
                                        url = builtins.concatStringsSep " / " ( builtins.concatLists [ path [ name ] ] ) ;
                                        in "${ seed }:  The value specified in ${ url } is a ${ type }." ;
                            pkgs = import nixpkgs { system = system ; } ;
                            in
                                {
                                    checks.testLib =
                                        pkgs.stdenv.mkDerivation
                                            {
                                                name = "test-lib" ;
                                                src = ./. ;
                                                installPhase =
                                                    let
                                                        try = lib "c9d69a6763d84ba0abf28187e9023778c6de4655aeb336a8be511360f39569a37eb92b8192d98f1b8b3912877a04ccb2b07884184169861194810acdd8c8c299" [ "a" "b" "c" ] "d" false ;
                                                        in
                                                            ''
                                                                ${ pkgs.coreutils }/bin/touch $out &&
                                                                    if [ "${ try }" != "c9d69a6763d84ba0abf28187e9023778c6de4655aeb336a8be511360f39569a37eb92b8192d98f1b8b3912877a04ccb2b07884184169861194810acdd8c8c299:  The value specified in a / b / c / d is a bool." ]
                                                                    then
                                                                        ${ pkgs.coreutils }/bin/echo ${ try }
                                                                            exit 1
                                                                    fi
                                                            '' ;
                                            } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
