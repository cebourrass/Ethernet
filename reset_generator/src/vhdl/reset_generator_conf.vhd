configuration reset_generator_conf of reset_generator_entity is
  use work.counter_comp.all;
  for reset_generator_arc
    for all : counter
      use configuration work.counter_conf;
    end for;
  end for;  
end configuration reset_generator_conf;