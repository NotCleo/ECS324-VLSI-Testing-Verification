module main;
  bit [0:1] y;
  bit [0:1] y_values[$] = '{1,3};
  bit [0:1] z;
  bit [0:1] z_values[$] = '{1,2};

  covergroup cg;
    //no bin declaration done here (default vec jump == 1)
    cover_point_y : coverpoint y ;
    cover_point_z : coverpoint z ;
    cross_yz : cross cover_point_y,cover_point_z ;
  endgroup

  cg cg_inst = new();

  initial
    foreach(y_values[i])
    begin
      y = y_values[i];
      z = z_values[i];
      cg_inst.sample();
    end

  final
    begin
      //Coverage of coverpoint y
      $display("coverage of coverpoint y = %0f",
      cg_inst.cover_point_y.get_coverage());
      //Coverage of coverpoint z
      $display("coverage of coverpoint z = %0f",
      cg_inst.cover_point_z.get_coverage());
      //Coverage of crosscoverpoint
      $display("CROSSCOVERAGE = %0f",
      cg_inst.cross_yz.get_coverage());
    end
endmodule
