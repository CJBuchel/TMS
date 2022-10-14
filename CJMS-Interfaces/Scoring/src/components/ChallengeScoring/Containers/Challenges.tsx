import { Component } from "react";

import "../../../assets/Challenge.scss";

import { Question } from "@cjms_interfaces/shared";
import Calculator, {CategoricalScore, NumericScore, Score, ScoreAnswer, ScoreError, ScoreResult} from "@ausfll/ausfll-score-calculator";

type Status = {
  score: number;
  validationErrors: ScoreError[];
}

interface IProps {

}

interface IState {
  data:ScoreResult[]
  status:Status
}

export default class Challenges extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      data:[],
      status: {score:0, validationErrors:[]}
    }
  }

  render() {

    var game = Calculator.SuperPowered;
    return(
      
      <Question
        key={game.scores[0].id}
        question={game.scores[0]}
        value={this.state.data.find((r) => r.id === game.scores[0].id)?.answer}
        unanswered={this.state.status.validationErrors
          .map((e) => e.id)
          .join(",")
          .includes(game.scores[0].id)
        }
        onChange={(v) => {}}
        errors={this.state.status.validationErrors
          .filter((v) => v.id && v.id.includes(game.scores[0].id))
          .map((v) => v.message.replace(/^Mission \d+ - /, ""))
        }
      />
    );
  }
}