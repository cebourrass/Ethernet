configuration tse_config_conf of tse_config_entity is
  use work.ip_stack_pack.all;
  use work.counter_comp.all;
  for tse_config_arc
    for all : counter
      use configuration work.counter_conf;
    end for;
  end for;  
end configuration tse_config_conf;

configuration udp_status_conf of udp_status_entity is
  use work.ip_stack_pack.all;
  use work.counter_comp.all;
  for udp_status_arc
    for all : counter
      use configuration work.counter_conf;
    end for;
  end for;  
end configuration udp_status_conf;

configuration udp_video_conf of udp_video_entity is
  use work.ip_stack_pack.all;
  use work.counter_comp.all;
  for udp_video_arc
    for all : counter
      use configuration work.counter_conf;
    end for;
  end for;  
end configuration udp_video_conf;

configuration ip_stack_conf of ip_stack_entity is
  use work.ip_stack_pack.all;
  use work.counter_comp.all;
  for syn
    for all : tse_config
      use configuration work.tse_config_conf;
    end for;
    for all : udp_status
      use configuration work.udp_status_conf;
    end for;    
    for all : udp_video
      use configuration work.udp_video_conf;
    end for;
  end for;  
end configuration ip_stack_conf;