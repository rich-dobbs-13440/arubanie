/*

    Usage:
    
    include <logging.scad>
    
*/

/* [Hidden] */

CRITICAL = 50; 
FATAL = CRITICAL;
ERROR = 40; 
WARNING = 30; 
WARN = WARNING;
INFO = 20; 
DEBUG = 10; 
NOTSET = 0;

IMPORTANT = 25;


// ----------Copy this section into your usage file -------------

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);

// ---------End of section-------------------


function console_styling(level) = 
    level >= IMPORTANT ? "<b style='color:OrangeRed'><font size=\"+2\">" :
    "";

function log_verbosity_choice(choice) = 
    choice == "WARN" ? WARN :
    choice == "INFO" ? INFO : 
    choice == "DEBUG" ? DEBUG : 
    NOTSET;
    
module log_s(label, s, verbosity, level=INFO, important=0) {
    overridden_level = max(level, important);
    if (overridden_level >= verbosity) { 
        style = console_styling(overridden_level);
        echo(style, label, s);
    }
}

function log_v1_styled(label, v1, style_level) = 
    let (
        style = console_styling(style_level),
        dummy1 = echo(style, "---"),
        dummy2 = echo(style, label, "= ["),
        dummy3 = [for (v = v1) echo(style, "-........", v)],
        dummy4 = echo(style, "-------]")
    )
    echo(style, " ");


function log_v1(label, v1, verbosity, level=INFO, important=0) =
    let (
        overridden_level = max(level, important),
        dummy = overridden_level >= verbosity ? log_v1_styled(label, v1, overridden_level) : undef
    )
    echo();

module log_v1(label, v1, verbosity, level=INFO, important=0) {
    overridden_level = max(level, important);
    if (overridden_level >= verbosity) { 
        style = console_styling(overridden_level);
        echo(style, "---");
        echo(style, label, "= [");
        for (v = v1) {
            echo(style, "-........", v);
        }
        echo(style, "-------]");
        echo(style, " ");
    }
} 

module joe() {
    echo("Module Joe!");
}

//dummywww = log_v1("My something", [4, 3, 2, 1,], INFO, IMPORTANT);
//function joe() = echo("Function Joe!!!!!");
//
//echo(joe());
//joe();
//
//dummyx = log_v1_styled("Sam", ["SamValue"], IMPORTANT);
//
//dummy = joe();