import React, { Component } from "react";

import "../../../assets/Challenge.scss";

import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import Question from "./Question";
import Calculator from "ausfll-score-calculator";
import { CategoricalScoreResult, NumericScoreResult, Score, ScoreError, ScoreResult, Game, ScoreAnswer } from "ausfll-score-calculator/dist/game-types";


type Status = {
  score: number;
  validationErrors: ScoreError[];
}


interface IProps {}

interface IState {
  data:ScoreResult[];
  status:Status;
  game:Game;
}

export default class Challenges extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      data:[],
      game: Calculator.SuperPowered,
      status: {score:0, validationErrors:[
        { message: `${Calculator.SuperPowered.missions.length} unanswered questions!` }
      ]}
    }
  }

  componentDidMount(): void {
    this.setDefaults();
  }

  setDefaults(e?:React.MouseEvent<HTMLButtonElement>) :ScoreResult[] | undefined {
    if (e) e.preventDefault();
    const d = this.state.game.scores.map((m:Score) => {
      return {
        ...m,
        answer: m.type === "numeric" ? `${m.defaultValue}` : m.defaultValue,
      };
    });

    this.setState({data: d});
    this.updateScore(d);
    return d;
  }

  updateScore(res:ScoreResult[]) {
    const val = this.state.game.validate(res);
    const sc = this.state.game.score(res);
    const newStatus:Status = {
      ...this.state.status,
      score: sc,
      validationErrors: val
    }

    this.setState({status: newStatus})
  }

  setResponse(id:Score["id"], answer:ScoreResult["answer"]) {
    console.log(id);
    console.log(answer);

    const d = this.state.data.map((r) => {
      if (r.id !== id) return r;
      if (Calculator.GIsNumericScore(r)) {
        return {...r, answer} as NumericScoreResult;
      } else {
        return {...r, answer} as CategoricalScoreResult;
      }
    });

    this.setState({data: d});
    this.updateScore(d);
  }

  getQuestions() {
    return (
      this.state.game.scores.map((q) => (
        <Question
          key={q.id}
          question={q}
          value={this.state.data.find((r) => r.id === q.id)?.answer}
          unanswered={this.state.status.validationErrors
            .map((e) => e.id)
            .join(",")
            .includes(q.id)
          }

          onChange={(v) => {this.setResponse(q.id, v)}}
          errors={this.state.status.validationErrors
            .filter((v) => v.id && v.id.includes(q.id))
            .map((v) => v.message.replace(/^Mission \d+ - /, ""))
          }
        />
      ))
    )
  }

  render() {
    console.log(this.state.status.score);
    if (this.state.status.validationErrors.length > 0) {
      console.log(this.state.status.validationErrors);
    }
    return(
      <div>
        <Table>
          <TableBody>
            {this.getQuestions()}
          </TableBody>
        </Table>
      </div>
    );
  }
}