/*

Features:
    * Larger font size since the console window font size can't be changed from GUI.
    * Color coding of message.
    * Prettier printing of vectors by rows..
    * Control of output level from customizer
    * Structured to encourage labeling output.

Usage:

include <lib/logging.scad>

The logging level constants are:

*/

CRITICAL = 50 + 0; 
FATAL = CRITICAL + 0;
ERROR = 40 + 0;
WARNING = 30 + 0;
WARN = WARNING + 0;
INFO = 20 + 0;
DEBUG = 10 + 0;
NOTSET = 0 + 0;

/*

    Add the contents of the logging_customize_section module to your
    customizer section.  The module is just there to hide
    these lines from inclusion.

*/ 


module logging_customize_section() {

    /* [Logging] */

    log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
    verbosity = log_verbosity_choice(log_verbosity_choice);    
}


/*  

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


module end_of_customization() {}




show_name = false;
if (show_name) {
    linear_extrude(2) text("logging.scad", halign="center");
}


IMPORTANT = 25 + 0;

big_fonts = false;
font_size = big_fonts ? "<font size='+1'>" : "<code>";


function console_styling(level) =
    level >= WARNING ? str("<b style='background-color:LightSalmon'>", font_size) : 
    level >= IMPORTANT ? str("<b style='color:OrangeRed'>", font_size) : 
    font_size;

function log_verbosity_choice(choice) = 
    choice == "WARN" ? WARN :
    choice == "INFO" ? INFO : 
    choice == "DEBUG" ? DEBUG : 
    NOTSET;
 
 
function log_s(label, s, verbosity=NOTSET, level=INFO, important=0) = 
    let(
        overridden_level = max(level, important),
        style = console_styling(overridden_level), 
        dmy1 = overridden_level >= verbosity ? echo (style, label, s) : undef
        
    )
    undef;
    
    
module log_s(label, s, verbosity=NOTSET, level=INFO, important=0) {
    overridden_level = max(level, important);
    if (overridden_level >= verbosity) { 
        style = console_styling(overridden_level);
        echo(str(style, parent_module(1), "() - ", label), s);
    }
}


function log_v1_styled(label, v1, style_level, nesting=0) = 
    let (
        style = console_styling(style_level),
        modified_label = nesting == 0 ? str(label, "= ") : "---",
        dummy1 = nesting==0 ? echo(str(style, "---")):undef,
        dummy2 = echo(str(style, modified_label, "[")),
        dummy3 = [for (v = v1) echo(str(style, "........", v))],
        dummy4 = echo(str(style, "---]"))
    )
    undef;


function log_v1(label, v1, verbosity, level=INFO, important=0) =
    let (
        overridden_level = max(level, important),
        dummy = overridden_level >= verbosity ? log_v1_styled(label, v1, overridden_level) : undef
    )
    undef;


function log_v2_styled(label, v2, style_level) = 
    let (
        style = console_styling(style_level),
        dummy1 = echo(str(style, "...")),
        dummy2 = echo(str(style, label, "= [")),
        dummy3 = [for (v = v2) log_v1_styled("", v, style_level, nesting=1)],
        dummy4 = echo(str(style, "]"))
    )
    undef;


function log_v2(label, v2, verbosity, level=INFO, important=0) =
    let (
        overridden_level = max(level, important),
        dummy = overridden_level >= verbosity ? log_v2_styled(label, v2, overridden_level) : undef
    )
    undef;


module log_v2(label, v2, verbosity, level=INFO, important=0) {
    dummy=log_v2(label, v2, verbosity, level=level, important=important);
    children();
}


module log_v1(label, v1, verbosity, level=INFO, important=0) {
    caller = parent_module(1);
    overridden_level = max(level, important);
    if (overridden_level >= verbosity) { 
        style = console_styling(overridden_level);
        echo(str(style, "---"));
        echo(str(style, caller, "() ", label, "= ["));
        for (v = v1) {
            echo(str(style, "-........", v));
        }
        echo(str(style, "-------]"));
        echo(str(style, " "));
    }
} 


module warn(condition, condition_as_text, warning, consequence) {
    if (!condition) {
        // Quick and dirty implementation!
        log_s(condition_as_text, warning , INFO, level=WARNING);
        log_s("Consequence", consequence, INFO, level=WARNING);
    }
}

function assert_msg(c1, c2, c3, c4, c5) = 
    let (
        s1 = is_undef(c1) ? "" : c1,
        s2 = is_undef(c2) ? "" : c2,
        s3 = is_undef(c3) ? "" : c3,
        s4 = is_undef(c4) ? "" : c4,
        s5 = is_undef(c5) ? "" : c5,
        last = undef
    )
    str("In module '", parent_module(0), "' ", s1, s2, s3, s4, s5);