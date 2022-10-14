import React, { useEffect, useState } from "react";
import Calculator, {CategoricalScore, NumericScore, Score, ScoreAnswer} from "@ausfll/ausfll-score-calculator";

import TextField from "@mui/material/TextField";
import TableRow from "@mui/material/TableRow";
import TableCell from "@mui/material/TableCell";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import FormControlLabel from "@mui/material/FormControlLabel";
// import Tooltip from "@mui/material/Tooltip";

type BaseProps = {
  question: Score;
  value?: ScoreAnswer["answer"];
  unanswered: boolean;
  onChange?: (v: ScoreAnswer["answer"]) => void;
  errors?: string[];
}

type NumericProps = BaseProps & {
  question: NumericScore;
}

const NumericQuestion = ({question, value, errors, onChange}: NumericProps) => {
  return (
    <TableRow className="">
      <TableCell className="">
        <div className="">
          <span>{question.label}</span>
          {errors?.map((e, i) => (
            <span key={i}>{e}</span>
          ))}
        </div>
      </TableCell>
      <TableCell className="">
        {onChange ? (
          <TextField
            type="number"
            value={Number(value) ?? question.defaultValue}
            InputProps={{
              inputProps: { max: question.max, min: question.min },
            }}
            onChange={(e) => onChange(e.target.value)}
          />
        ) : (
          <span>{value ?? "?"}</span>
        )}
      </TableCell>
    </TableRow>
  );
}

type CategoricalProps = BaseProps & {
  question: CategoricalScore;
}

const CategoricalQuestion = ({question, value, onChange, errors}: CategoricalProps) => {
  const [val, setVal] = useState<string | undefined>(value);

  const handleChange = (s: string) => {
    if (!onChange) return;
    setVal(s);
    onChange(s);
  }

  useEffect(() => {
    setVal(value);
  }, [value]);

  return (
    <TableRow className="">
      <TableCell className="">
        <div className="">
          <span>{question.label}</span>
        </div>
      </TableCell>
      <TableCell className="">
        <RadioGroup
          row
          value={val ?? null}
          onChange={(e) => (onChange ? handleChange(e.target.value) : {})}
        >
          {question.options.map((opt, key) => (
            <FormControlLabel
              key={key}
              value={opt}
              control={<Radio />}
              label={String(opt).replace(/_/g, " ")}
            />
          ))}
        </RadioGroup>
      </TableCell>
    </TableRow>
  );
}

export const Question = ({question, value, errors, ...rest}: BaseProps) => {
  return Calculator.GIsCategoricalScore(question) ? (
    <CategoricalQuestion
      question={question}
      value={value}
      errors={errors?.filter((x,i,a) => a.indexOf(x) === i)}
      {...rest}
    />
  ) : (
    <NumericQuestion
      question={question}
      value={value}
      errors={errors?.filter((x, i, a) => a.indexOf(x) === i)}
      {...rest}
    />
  );
}

export default Question;