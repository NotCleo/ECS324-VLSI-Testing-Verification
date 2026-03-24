class driver;
  virtual seq_if vif; 
  
  //seq_if is  the name given to the Interface block. 
  // so virtual seq_if is like making that interface virtual and then that vif is an object of the virtual interface, which now represents the bundle of wires declared in interface.sv
  
   //why we use virtual keyword? The most common use is for declaring a "virtual interface" which acts as a pointer or a handle to a physical (static) interface instance connected to the Design Under Test (DUT)
  
  /*
  defined seq_if as a bundle of physical hardware wires. It groups together all the signals needed to talk to your sequence detector:

    clk 

    reset 

    din 

    dout 

    current_state 
  */
  
  
  //Instead of manually typing out .clk(clk), .reset(reset), .din(din), .dout(dout) every single time if we want to connect a testbench component to the DUT, just pass the single seq_if bundle.
  
  //vif is just a software pointer. It bridges the gap b/w dynamic OOP software (driver.sv) to toggle the physical static hardware pins (interface.sv) connected to the sequence detector
    
  mailbox #(transaction) gen2driv;
  //gen2driv is the name of the mailbox handle/object
  //mailbox will only hold objects of the transaction class type.
  
  //regarding vif : https://verificationguide.com/systemverilog/systemverilog-virtual-interface/

  function new(virtual seq_if vif, mailbox #(transaction) gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

	task run();
    forever begin
      transaction trans;   //Declare a blank handle/object to hold a transaction
      gen2driv.get(trans); //Reach into the mailbox and pull out a single randomized transaction packet.
      
      @(posedge vif.clk);  //Wait for the physical hardware clock to go high.
      vif.din <= trans.din; //Take the 'din' bit from the packet from that trans handle and physically drive it onto the hardware wire.
      
    end
  endtask
endclass

