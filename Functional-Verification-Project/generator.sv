class generator;
  //since transaction sits in front of the generator, we instantiate an object of transaction class here in order to perform the mailbox transfer from gen2driv
  
  transaction trans;
  mailbox #(transaction) gen2driv; //gen2driv is the method instance of the mailbox 
 
  //gen2driv is the name of the mailbox handle
  //mailbox will only hold objects of the transaction class type.

  
  /* Regarding the dot operator (.) ; 
  It is primarily used for hierarchical referencing, member access (in classes/structs/interfaces), and port connections (named mapping). It enables accessing signals deep in the design, invoking class methods, or implicitly connecting ports by name, replacing tedious positional mapping    
  */
  
  
  function new(mailbox #(transaction) gen2driv);
    this.gen2driv = gen2driv; 
    //The "this" keyword in SystemVerilog is a predefined class handle that refers to the current class instance. It is used within non-static class methods to access the properties and methods of that specific object. 
    
    
// this.gen2driv is the handle of the mailbox method
    
//about "this." operator, referred here - https://verificationguide.com/systemverilog/systemverilog-this-keyword/
    
/*
this keyword shall only be used within non-static class methods
this keyword refers to the object handle in which it is invoked
*/
    
  endfunction
  
  
  

  task run(); 
    for(int i = 0; i < 100; i++) begin
      trans = new();
// The new() function is called a class constructor and is a way to initialize the class variables with some value. Note that it does not have a return type and is non-blocking.
      
      if(!trans.randomize()) $error("Randomization failed");
      //.randomize(): A built-in class method that triggers the constraint solver to generate values for any variable marked rand
      
      gen2driv.put(trans);
      
// .put(): This is a blocking task used by a producer process to place a message (typically a class object handle) into the mailbox and .get(): This is a blocking task used by a consumer process to retrieve a message from the mailbox and remove it from the queue.
    end
  endtask
  
endclass