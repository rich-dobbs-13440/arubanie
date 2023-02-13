/*

    Make up for the lack of common vector operations.

    Usage:

        use <vector_operations.scad>

*/

module end_of_customization() {}

show_name = false;
if (show_name) {
    linear_extrude(2) text("vector_operations.scad", halign="center");
}

function quicksort(arr) = !(len(arr)>0) ? [] : let(
    pivot   = arr[floor(len(arr)/2)],
    lesser  = [ for (y = arr) if (y  < pivot) y ],
    equal   = [ for (y = arr) if (y == pivot) y ],
    greater = [ for (y = arr) if (y  > pivot) y ]
) concat(
    quicksort(lesser), equal, quicksort(greater)
);

// Cumulative sum of values in v
function v_cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    
function v_sum(v, i=0, r=0) = i<len(v) ? v_sum(v, i+1, r+v[i]) : r;

function v_add_scalar(v, s) = [ for (e = v) e + s ];
    
function v_sub_scalar(v, s) = [ for (e = v) e - s ];
    
function v_mul_scalar(v, s) = [ for (e = v) e * s ];

function v_set(v) = let(sv = quicksort(v)) [for (i = [0: 1 : len(v)-1 ]) if (i == 0) sv[i] else if (sv[i] != sv[i-1]) sv[i]];

function v_shorten(v, places) = [ for (idx = [0 : 1: places-1]) v[idx]];

// The add operation is reasonably as the + operator in the language itself. 
 

function a2_add_scalar(a, s) = [ for (ae = a) v_add_scalar(ae, s) ];

// Array should be rectangular, with the same number
// of elements in each contained list.  
// That makes it different from a generic C style lists of list.
function array_transpose(a) = 
    [ for (j = [0 : 1 : len(a[0])-1]) 
        [ for (i =[0 : 1 : len(a)-1])
          a[i][j]  
        ]
    ];
        
        
module test_array_transpose() {
    a = [["cat1", "dog1"],
         ["cat2", "dog2"]]; 
    * echo("a", a);
    * echo("aT", array_transpose(a));
}

* test_array_transpose();

//Hadamard Product - - a & b must be same dimensioon
function v_o_dot(v_a, v_b) = 
    assert(len(v_a) == len(v_b), str("len(v_a)=", len(v_a), "len(v_b)=", len(v_b)))
    [ for (i = [0 : len(v_a)-1]) v_a[i] * v_b[i] ];


         