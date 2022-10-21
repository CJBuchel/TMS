import mongoose from "mongoose";
import { IEvent, IOnlineLink } from "@cjms_shared/services";

export const OnlineLinkSchema = new mongoose.Schema<IOnlineLink>({
  tournament_id: {type: String},
  tournament_token: {type: String},
  online_linked: {type: Boolean, default: false}
});

export const EventSchema = new mongoose.Schema<IEvent>({
  event_name: {type: String, required: true},
  event_csv: {type: JSON, required: true},
  
  event_tables: [{type: String}],
  event_rounds: {type: Number, default: 3},
  
  season: {type: Number, required: true},
  
  match_locked: {type: Boolean, default: true},
  online_link: OnlineLinkSchema
}, {
  capped: { size: 102400, max: 1, autoIndexId: true } // we only want one event document
});

export const EventModel = mongoose.model<IEvent>('Event', EventSchema);