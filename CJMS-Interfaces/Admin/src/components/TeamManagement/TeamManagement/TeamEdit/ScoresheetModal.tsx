import { CJMS_POST_SCORE, CJMS_POST_TEAM_UPDATE, CJMS_REQUEST_EVENT, Question } from "@cjms_interfaces/shared";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import Calculator from "ausfll-score-calculator";
import { CategoricalScoreResult, NumericScoreResult, Score, ScoreError, ScoreResult, Game } from "ausfll-score-calculator/dist/game-types";
import { Button, TableCell, TableRow, TextField } from "@mui/material";
import { comm_service, initITeamScore, ITeam, ITeamScore } from "@cjms_shared/services";
import { IEvent } from "@cjms_shared/services/lib/components/InterfaceModels/Event";
import { Component, Fragment } from "react";

import CloseIcon from "@mui/icons-material/Close";

import "../../../../assets/ScoresheetModal.scss";

type Status = {
  score: number;
  validationErrors: ScoreError[];
}

interface IProps {
  display:boolean;
  existing_scoresheet:boolean;
  team:ITeam;
  scoresheet:ITeamScore;
  scoresheet_index:number;

  closeCallback:Function;
}

interface IState {
  data:ScoreResult[];
  status:Status;
  external_eventData?:IEvent;
  game:Game;
  publicComment:string;
  privateComment:string;
}

export default class ScoresheetModal extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      data: [],
      status: {score:0, validationErrors:[
        { message: `${Calculator.SuperPowered.missions.length} unanswered questions!` }
      ]},
      game: Calculator.Games[0],

      publicComment: '',
      privateComment: ''
    }

    comm_service.listeners.onEventUpdate(async () => {
      CJMS_REQUEST_EVENT().then((event) => {
        this.setEventData(event);
      });
    });

    this.handleSubmit = this.handleSubmit.bind(this);
    this.setDefaults = this.setDefaults.bind(this);
    this.handleNoShow = this.handleNoShow.bind(this);
  }

  async handleScoreSubmit(score:ITeamScore) {
    var team_update = this.props.team;

    if (this.props.existing_scoresheet) {
      score.referee = 'TM-Admin';
      score.valid_scoresheet = true;
      team_update.scores[this.props.scoresheet_index] = score;
      CJMS_POST_TEAM_UPDATE(this.props.team.team_number, team_update).then(() => {
        this.props.closeCallback();
      });
    } else {
      score.referee = 'TM-Admin';
      score.valid_scoresheet = true;
      CJMS_POST_SCORE(this.props.team.team_number, score).then(() => {
        this.props.closeCallback();
      });
    }
  }

  async handleNoShow() {
    var scoresheet = this.props.scoresheet;
    scoresheet.no_show = true;
    this.handleScoreSubmit(scoresheet);
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

    this.handleScoreSubmit(scoresheet);
  }

  setEventData(event:IEvent) {
    this.setState({external_eventData: event});
    this.setState({game: Calculator.Games.find((game) => game.season === event.season) || Calculator.Games[0]});
  }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any): void {
    if (this.props != prevProps) {
      if (this.props.existing_scoresheet) {
        this.initData();
      } else {
        this.setDefaults();
      }
    }
  }

  componentDidMount(): void {
    CJMS_REQUEST_EVENT().then((event) => {
      this.setEventData(event);
      if (this.props.existing_scoresheet) {
        this.initData();
      } else {
        this.setDefaults();
      }
    });
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

  initData() {
    const d = this.setDefaults();
    if (d) {
      const d2 = d.map((score) => ({
        ...score,
        answer: this.props.scoresheet.scoresheet.answers.find((i) => i.id === score.id)?.answer ?? score.answer
      }));

      this.setState({publicComment: this.props.scoresheet.scoresheet.public_comment});
      this.setState({privateComment: this.props.scoresheet.scoresheet.private_comment});
      
      this.setState({data: d2});
      this.updateScore(d2);
    }
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
    if (!this.props.display) return (<></>);
    return (
      <div className="ScoresheetModal">
        <Button
          startIcon={<CloseIcon/>}
          variant="outlined"
          sx={{
            width: '90%',
            marginBottom: '1%',
            marginTop: '1%',
            color: 'white',
            borderColor: 'white'
          }}
          onClick={() => {this.props.closeCallback()}}
        >Close</Button>

        <div className="scoresheet-mission">
          <Table>
            <TableBody>
              {this.getMissions()}
            </TableBody>
          </Table>
          {this.getComments()}
        </div>

        <div className="challenge-buttons">
          <Button
            variant="outlined"
            sx={{
              color: 'orange',
              borderColor: 'orange'
            }}
            onClick={() => {this.handleNoShow()}}
          >No Show</Button>

          <Button
            variant="outlined"
            sx={{
              color: 'red',
              borderColor: 'red',
            }}
            onClick={() => {this.setDefaults()}}
          >Clear</Button>
        </div>

        <div className="challenge-buttons">
          <Button
            variant="contained"
            sx={{
              backgroundColor: 'green',
              color: 'white',
              borderColor: 'green'
            }}
            onClick={() => {this.handleSubmit()}}
            disabled={this.state.status.validationErrors.length > 0}
          >Submit</Button>
        </div>
      </div>
    );
  }
}