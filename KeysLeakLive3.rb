samples = "C:/Users/calto/OneDrive/Documents/Live Coding/keysLeak"


use_osc '127.0.0.1', 12000
use_debug false

use_bpm 80
use_random_seed 50


live_loop :getDistortion do
  ##| d = 0.5
  d = sync "/osc/distortion"
  puts d
  set :dist,d[0]
end

live_loop :drone do
  with_fx :lpf, cutoff: (100+((get[:dist])*30)) do
    with_fx :distortion, distort: (1-(get[:dist])) do
      with_fx :reverb, room: 1 do
        sample samples, 4, amp: 10
        sleep 16
      end
    end
  end
end


live_loop :ambiance do
  with_fx :lpf, cutoff: (100+((get[:dist])*20)) do
    with_fx :distortion, distort: (1-(get[:dist])) do
      with_fx :bitcrusher, sample_rate: 20000 do
        sample samples, 1, amp: 8#, beat_stretch: 16
        sample samples, 2, amp: 8#, beat_stretch: 16
        
        sleep 16
      end
    end
  end
end

live_loop :notes, sync: :drone do
  with_fx :lpf, cutoff: (130*(get[:dist])) do
    with_fx :distortion, distort: (1-(get[:dist])) do
      with_fx :reverb do
        ##| with_fx :bitcrusher, sample_rate: 10000 do
        
        sample samples, (choose ([3,5])), amp: 10
        sleep (choose ([0.25,0.25,16]))
        osc "/viz/inputBell", (choose([5,25,50,75,100,]))
      end
    end
  end
end

live_loop :visuals, sync: :drone do
  osc "/viz/inputWave", (rrand_i(100,300))
  sleep 8
end

