import mongoose from "mongoose";
import { IEvent } from "@cjms_shared/services";

export const EventSchema = new mongoose.Schema<IEvent>({
  event_name: {type: String, required: true},
  event_csv: {type: JSON, required: true},

  event_tables: [{type: String}],
  event_rounds: {type: Number, default: 3},

  season: {type: Number, required: true, default: 20212022},

  match_locked: {type: Boolean, default: true}
}, {
  capped: { size: 102400, max: 1, autoIndexId: true } // we only want one event document
});

export const EventModel = mongoose.model<IEvent>('Event', EventSchema);