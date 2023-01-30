use <vector_operations.scad>


//a = 1;
//selector = function (which)
//             which == "add"
//             ? function (x) x + x + a
//             : function (x) x * x + a;
             
//echo(selector("add"));     // ECHO: function(x) ((x + x) + a)

my_dct = [
        ["wall", 2],
        ["floor", 3]
        
      ];
      
   
echo(my_dct);   
//b = array_transpose(my_dct);
//
//echo(b);


// Implemented as a linear search
function find_in_dct(dct, key) = [ for (item = dct) if (item[0] == key) item[1] ][0];  

echo(find_in_dct(my_dct, "floor")); 
echo(find_in_dct(my_dct, "wall"));
echo(find_in_dct(my_dct, "ceiling"));

// echo([][0]);