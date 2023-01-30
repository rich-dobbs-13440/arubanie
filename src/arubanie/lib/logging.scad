/*

Features:
    * Larger font size since the console window font size can't be changed from GUI.
    * Color coding of message.
    * Prettier printing of vectors by rows..
    * Control of output level from customizer
    * Structured to encourage labeling output.

Usage:

include <logging.scad>
    
Add this to your customizer section:    
    
/* [Logging] * /

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);    
    

Sample usage in code: 
    // DEBUG level assigned by default!
    log_s("air_brush_length", air_brush_length, verbosity);  
    
    // Really show this message because its important for immediately debugging
    log_s("air_brush_length", air_brush_length, verbosity, IMPORTANT);
   
    // Info message for aid in isolating a problem:
    log_s("Entering module", "module_name", verbosity, INFO);
    
    // Not a fatal error, but something the user should immediately 
    // spot in the log:
    log_s("Warning", "Message about the worry!", verbosity, WARN);
    
    // Show an array with somewhat prettier printing:
    log_v1("offsets", offsets, verbosity);
    
    // Dump out information relevant to an assertion failure
    if (assertion_condition) {
        log_v1("offsets", offsets, verbosity), ERROR);
        assert(assertion_condition, "msg")
    }
    
    warn(
        lp >= 2.5*h, 
        
        "Pintle length should be at least 2.5 times the height.",
        "The length is not sufficient to correctly implement rotation stops."
    );
    
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
    level >= WARNING ?
        "<b style='background-color:LightSalmon'><font size='+1'>" : 
    level >= IMPORTANT ? 
        "<b style='color:OrangeRed'><font size='+2\'>" :
    // otherwise
        "<font size=\"+2\">";

function log_verbosity_choice(choice) = 
    choice == "WARN" ? WARN :
    choice == "INFO" ? INFO : 
    choice == "DEBUG" ? DEBUG : 
    NOTSET;
 
 
function log_s(label, s, verbosity, level=DEBUG, important=0) = 
    let(
        overridden_level = max(level, important),
        style = console_styling(overridden_level), 
        dmy1 = overridden_level >= verbosity ? echo(style, label, s) : undef
        
    )
    undef;
    
    
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
    undef;


function log_v1(label, v1, verbosity, level=INFO, important=0) =
    let (
        overridden_level = max(level, important),
        dummy = overridden_level >= verbosity ? log_v1_styled(label, v1, overridden_level) : undef
    )
    undef;


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


module warn(condition, condition_as_text, warning, consequence) {
    if (!condition) {
        // Quick and dirty implementation!
        log_s(condition_as_text, warning , INFO, level=WARNING);
        log_s("Consequence", consequence, INFO, level=WARNING);
    }
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