import { RequestServer } from "../RequestServer";
import { request_namespaces, comm_service } from "@cjms_shared/services";
import { MatchModel } from "../../database/models/Match";


export class MatchControl {
  constructor(requestServer:RequestServer) {
    console.log("Match Control Requests Constructed");

    var existing_loadedMatch:boolean = false;
    var load_match:boolean = false;

    function sendLoadedMatch(match:string) {
      if (!existing_loadedMatch) {
        existing_loadedMatch = true;
        comm_service.senders.sendMatchLoadedEvent(match);

        const loopInterval = setInterval(loop, 1000);
        function loop() {
          if (load_match) {
            console.log("Loading match: " + match);
            comm_service.senders.sendMatchLoadedEvent(match);
          } else {
            existing_loadedMatch = false;
            clearInterval(loopInterval);
            comm_service.senders.sendMatchLoadedEvent(null);
          }
        }
      }
    }

    // Main countdown
    var countDownTime:number = 5; // 150
    var prerunTime:number = 5;
    var clockStop:boolean = false;
    var existingClock:boolean = false;
    var loaded_match:string = '';

    comm_service.listeners.onMatchLoaded((match:string) => {
      loaded_match = match;
    });

    function setMatchComplete(match:string, complete:boolean) {
      const filter = {match_number: match};
      const update = {complete: complete};
      MatchModel.findOneAndUpdate(filter, update, {}, (err) => {
        if (err) {
          console.log(err.message);
        } else {
          comm_service.senders.sendMatchUpdateEvent('update');
        }
      });
    }

    function startCountdown(duration:number) {
      if (!existingClock) {
        existingClock = true;
        
        comm_service.senders.sendClockTimeEvent(duration);
        var start = Date.now(),diff;
        var endgame = false;
        
        const timerInterval = setInterval(timer, 1000);
        function timer() {
          if (!clockStop) {
            diff = duration - (((Date.now() - start) / 1000) | 0);
        
            console.log(diff);
            comm_service.senders.sendClockTimeEvent(diff);
            comm_service.senders.sendEventStateEvent("Running");
        
            if (diff <= 30) {
              if (!endgame) {
                endgame = true;
                comm_service.senders.sendClockEndGameEvent(true);
              }
            }
        
            if (diff <= 0) {
              existingClock = false;
              console.log("Stopping counter");
              comm_service.senders.sendClockEndEvent(true);
              comm_service.senders.sendEventStateEvent("Idle");
              setMatchComplete(loaded_match, true);

              comm_service.senders.sendEventStateEvent("Idle");
              comm_service.senders.sendMatchLoadedEvent(null);
              load_match = false;

              clearInterval(timerInterval);
            }
          } else {
            existingClock = false;
            comm_service.senders.sendClockStopEvent(true);
            comm_service.senders.sendEventStateEvent("Aborted");
            clearInterval(timerInterval);
          }
        }
      
      }
    }

    function startPrerun(duration:number) {
      console.log("Prerun start");
      if (!existingClock) {
        existingClock = true;
        var start = Date.now(),diff;
        
        const timerInterval = setInterval(timer, 1000);
        function timer() {
          console.log("Timer loop");
          diff = duration - (((Date.now() - start) / 1000) | 0);
          if (!clockStop) {
            
            console.log(diff);
            
            comm_service.senders.sendEventStateEvent("Pre-Running");
            comm_service.senders.sendClockPrestartEvent(true);
            comm_service.senders.sendClockTimeEvent(diff);
        
            if (diff <= 0 || clockStop) {
              existingClock = false;
              startCountdown(countDownTime);
              comm_service.senders.sendClockStartEvent(true);
              clearInterval(timerInterval)
            }
          } else {
            existingClock = false;
            comm_service.senders.sendClockStopEvent(true);
            clearInterval(timerInterval)
          }
        }
      
      }
    }

    // Timer
    requestServer.get().post(request_namespaces.request_post_timer, (req, res) => {
      const state = req.body.timerState;
      console.log("From Timer: " + state);

      if (state === 'arm') {
        comm_service.senders.sendClockArmEvent(true);
      }

      if (state === 'prestart') {
        clockStop = false;
        comm_service.senders.sendClockPrestartEvent(true);
        startPrerun(prerunTime);
      }

      if (state === 'start') {
        clockStop = false
        comm_service.senders.sendClockStartEvent(true);
        startCountdown(countDownTime);
      }

      if (state === 'stop') {
        clockStop = true
        comm_service.senders.sendClockStopEvent(true);
        // setPrevMatch(); @todo
      }

      if (state === 'reload') {
        clockStop = true;
        comm_service.senders.sendClockReloadEvent(true);
      }

      res.send({});
    });

    // Match load
    requestServer.get().post(request_namespaces.request_post_match_load, (req, res) => {
      console.log(req.body);
      if (req.body.load) {
        load_match = true;
        comm_service.senders.sendEventStateEvent("Match Loaded");
        sendLoadedMatch(req.body.match);
      } else {
        comm_service.senders.sendEventStateEvent("Idle");
        comm_service.senders.sendMatchLoadedEvent(null);
        load_match = false;
      }
      
      res.send({});
    });
  }
}