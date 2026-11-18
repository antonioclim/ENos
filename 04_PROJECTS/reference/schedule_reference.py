#!/usr/bin/env python3
"""Finite numeric cron reference. Output is a plan, never an installed schedule.

Supported: five numeric fields with *, lists, inclusive ranges and /steps.
Names, @macros and special day operators are rejected. 'every N hours/minutes'
means wall-clock aligned slots only when N divides 24/60; it is not monotonic time.
Calendar conversion uses the supplied timezone and preserves cron DOM/DOW union.
"""
from __future__ import annotations
import re
import sys
from zoneinfo import ZoneInfo
RANGES=((0,59),(0,23),(1,31),(1,12),(0,7))
WEEKDAYS=('Sun','Mon','Tue','Wed','Thu','Fri','Sat')


def values(field: str, low: int, high: int) -> list[int]:
    result=set()
    for piece in field.split(','):
        match=re.fullmatch(r'(\*|\d+(?:-\d+)?)(?:/([1-9]\d*))?', piece)
        if not match: raise ValueError(f'unsupported cron field: {field}')
        stem, step=match.groups(); step=int(step or 1)
        if stem=='*': start,end=low,high
        elif '-' in stem: start,end=map(int,stem.split('-'))
        else:
            if match[2] is not None: raise ValueError('a step needs * or an explicit range')
            start=end=int(stem)
        if not low<=start<=end<=high: raise ValueError('cron value outside field range')
        result.update(range(start,end+1,step))
    return sorted(result)


def parse(expression: str) -> str:
    aliases={'every minute':'* * * * *','hourly':'0 * * * *','daily':'0 0 * * *','weekly':'0 0 * * 0'}
    expression=aliases.get(expression.strip(),expression.strip())
    if match:=re.fullmatch(r'every ([1-9]\d*) (minutes?|hours?)',expression):
        n=int(match[1]); hours=match[2].startswith('hour'); base=24 if hours else 60
        if n>base or base%n: raise ValueError('interval is not a uniform wall-clock divisor; use an explicit monotonic timer')
        expression=f'0 */{n} * * *' if hours else f'*/{n} * * * *'
    if match:=re.fullmatch(r'daily at (\d{1,2})(?::(\d{2}))?(am|pm)?',expression):
        hour=int(match[1]); minute=int(match[2] or 0); suffix=match[3]
        if suffix:
            if not 1<=hour<=12: raise ValueError('invalid 12-hour clock')
            hour=hour%12+(12 if suffix=='pm' else 0)
        if hour>23 or minute>59: raise ValueError('invalid clock time')
        expression=f'{minute} {hour} * * *'
    fields=expression.split()
    if len(fields)!=5: raise ValueError('expected five cron fields')
    for field,(low,high) in zip(fields,RANGES): values(field,low,high)
    return ' '.join(fields)


def calendars(expression: str, timezone: str) -> list[str]:
    ZoneInfo(timezone)
    minute,hour,dom,month,dow=parse(expression).split()
    fmt=lambda field,bounds: '*' if field=='*' else ','.join(map(str,values(field,*bounds)))
    minute_text=fmt(minute,RANGES[0]); hour_text=fmt(hour,RANGES[1])
    month_text=fmt(month,RANGES[3]); dom_text=fmt(dom,RANGES[2])
    weekday='' if dow=='*' else ','.join(WEEKDAYS[i] for i in sorted({v%7 for v in values(dow,0,7)}))+' '
    make=lambda days,prefix: f'{prefix}*-{month_text}-{days} {hour_text}:{minute_text}:00 {timezone}'
    if not dom.startswith('*') and not dow.startswith('*'):
        return [make(dom_text,''),make('*',weekday)]
    return [make(dom_text,weekday)]


def main(argv: list[str]) -> int:
    try:
        if len(argv)==2 and argv[0]=='parse': print(parse(argv[1]))
        elif len(argv)==3 and argv[0]=='calendar': print('\n'.join(calendars(argv[1],argv[2])))
        else: raise ValueError('usage: schedule_reference.py parse EXPR | calendar EXPR TIMEZONE')
        return 0
    except (ValueError,KeyError) as error:
        print(f'Schedule rejected: {error}',file=sys.stderr);return 2
if __name__=='__main__': raise SystemExit(main(sys.argv[1:]))
