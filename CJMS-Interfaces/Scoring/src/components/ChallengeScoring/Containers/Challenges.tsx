import React, { Component, Fragment } from "react";

import "../../../assets/Challenge.scss";

import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import Question from "./Question";
import Calculator from "ausfll-score-calculator";
import { CategoricalScoreResult, NumericScoreResult, Score, ScoreError, ScoreResult, Game, ScoreAnswer } from "ausfll-score-calculator/dist/game-types";
import { Button, TableCell, TableRow, TextField } from "@mui/material";
import { margin } from "@mui/system";
import { initITeamScore, ITeamScore } from "@cjms_shared/services";


type Status = {
  score: number;
  validationErrors: ScoreError[];
}


interface IProps {
  handleScoreSubmit:Function;
  handleScoreChange:Function;
}

interface IState {
  data:ScoreResult[];
  status:Status;
  game:Game;
  publicComment:string;
  privateComment:string;

  team_scoresheet:ITeamScore;
}

export default class Challenges extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      data:[],
      game: Calculator.SuperPowered,
      status: {score:0, validationErrors:[
        { message: `${Calculator.SuperPowered.missions.length} unanswered questions!` }
      ]},

      publicComment: '',
      privateComment: '',

      team_scoresheet: initITeamScore()
    }

    this.handleSubmit = this.handleSubmit.bind(this);
    this.setDefaults = this.setDefaults.bind(this);
  }

  async handleSubmit() {
    // Complete validation and score once more before submitting
    const val = this.state.game.validate(this.state.data);
    const sc = this.state.game.score(this.state.data);

    if (val.length > 0) {
      alert("Cannot submit score, invalid scoresheet");
      return;
    }
  
    var scoresheet:ITeamScore = initITeamScore();
    scoresheet.score = sc;
    scoresheet.gp = this.state.data.find((e) => e.id.startsWith("gp"))?.answer || "";
    scoresheet.scoresheet.public_comment = this.state.publicComment;
    scoresheet.scoresheet.private_comment = this.state.privateComment;
    scoresheet.scoresheet.answers = this.state.data.map(({id, answer}) => ({id: id, answer: answer}));

    this.props.handleScoreSubmit(scoresheet);
  }

  componentDidMount(): void {
    this.setDefaults();
  }

  setPublicComment(e:string) {
    this.setState({publicComment: e});
  }

  setPrivateComment(e:string) {
    this.setState({privateComment: e});
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
    this.props.handleScoreChange(newStatus.score);
  }

  setResponse(id:Score["id"], answer:ScoreResult["answer"]) {
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

  getQuestion(prefix:string) {
    return (
      this.state.game.scores
      .filter((q) => q.id.startsWith(prefix))
      .map((q) => (
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
    );
  }

  getMissions() {
    return (
      <>
        {this.state.game.missions
          .map(({title, prefix, image}, i) => (
            <Fragment key={prefix}>
              <TableRow sx={{background: 'white'}}>
                <TableCell 
                  sx={i > 0 ? {borderBottom: 'none', borderTop: '1px solid', borderTopLeftRadius: '20px'} : {borderBottom: 'none', borderTopLeftRadius: '20px'}}
                  colSpan={2}
                  component="th"
                >
                  <div style={{display: 'flex', flexDirection: 'row', alignItems: 'center'}}>
                    <img 
                      src={image ?? "https://www.firstlegoleague.org/sites/default/files/color/fll_theme-474df67b/fll-logo-horizontal.png"}
                      style={{marginRight: 16, height: 64, width: 'auto'}}
                    />
                    <h4>{title}</h4>
                  </div>
                </TableCell>
              </TableRow>
              {this.getQuestion(prefix)}
            </Fragment>
          ))
        }
      </>
    );
  }

  getComments() {
    return (
      <div style={{display: 'flex', flexDirection: 'column', background: 'white', paddingTop: 10}}>
        <TextField
          label="Public comment"
          sx={{marginBottom: 5}}
          value={this.state.publicComment}
          onChange={(e) => this.setPublicComment(e.target.value)}
          placeholder="Enter a comment that the team might see - stay positive and constructive!"
          maxRows={4}
          multiline
        />
        <TextField
          label="Private comment"
          sx={{marginBottom: 5}}
          value={this.state.privateComment}
          onChange={(e) => this.setPrivateComment(e.target.value)}
          placeholder="Enter a comment for other referees/judges - the team cannot see this one."
          maxRows={4}
          multiline
        />
      </div>
    );
  }

  render() {
    return(
      <div className="challenges-container">
        <Table>
          <TableBody>
            {this.getMissions()}
          </TableBody>
        </Table>
        {this.getComments()}

        <Table>
          <TableBody>
            <TableRow>
              <TableCell>
                <div className="challenge-buttons">
                  <button onClick={this.handleSubmit} disabled={this.state.status.validationErrors.length > 0} className={`hoverButton ${this.state.status.validationErrors.length > 0 ? "" : "back-green"}`}>Submit</button>
                </div>
              </TableCell>

              <TableCell>
                <div className="challenge-buttons">
                  <button onClick={this.setDefaults} className="hoverButton back-red">Clear</button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    );
  }
}