# Romanian addition: reflexive clitics and omitted subjects

The extension uses the existing Lambek engine to model clitic agreement
(`mă culc`, `te culci`) and optional subject pronouns (`eu știu` / `știu`).
It covers present-indicative forms of three reflexive verbs (`a se culca`,
`a se spăla`, `a se trezi`) and two ordinary verbs (`a ști`, `a dormi`).

## Demonstration

Follow [README.md](../README.md) and choose `romanian.elx` and `roworld.py`.
Example truth values in the toy world:

| Explicit subject | Omitted subject | Result |
| --- | --- | --- |
| eu știu | știu | True; omitted form also has a False third-person plural reading |
| tu știi | știi | True |
| eu mă culc | mă culc | True |
| tu te culci | te culci | False |
| eu mă trezesc | mă trezesc | False |
| ei se trezesc | se trezesc | True |

`False` means a grammatical sentence is false in the supplied world.
Shared forms retain multiple readings: `știu` and `dorm` allow first-person
singular or third-person plural; `se culcă` allows third-person singular or plural.
A clitic can resolve ambiguity: `mă trezesc` is first-person singular,
while `se trezesc` is third-person plural.

## Grammatical types

Subject and reflexive-verb types encode person and number (`np1sg`, `rv1sg`, etc.):

```text
Eu   : np1sg
Mă   : (np1sg \ s) / rv1sg
Mă   : s / rv1sg
Culc : rv1sg
```

The first `Mă` entry builds a predicate requiring `eu` on its left; the second
supplies the speaker and builds a sentence. These types derive `eu mă culc`
and `mă culc`, but reject `eu te culci`, `mă culci`, and bare `culc`.

Ordinary verbs similarly have predicate and complete-sentence entries:

```text
Știu : np1sg \ s = lambda subjects : subjects <= know_answer.
Știu : s          = speaker <= know_answer.
Știu : np3pl \ s = lambda subjects : subjects <= know_answer.
Știu : s          = they <= know_answer.
```

Subject omission is handled by lexical meanings using fixed conversational
referents. The parser inserts no invisible pronouns.

## Reflexive meanings

A verb denotes a curried relation, such as `lambda x: lambda y: (x, y) in wash`.
The explicit-subject clitic applies it to each subject twice:

```python
lambda verb: lambda subjects: all(verb(x)(x) for x in subjects)
```

Each person must act on themselves: `('Ioana', 'Ana')` does not make
`ea se spală` true for Ioana. Plural readings are distributive, not reciprocal.
Argument duplication occurs in the Python meaning; the Lambek derivation still
uses each word once. Self-pairs for `culca` and `trezi` simplify their meanings.

## Vocabulary

| Person | Clitic | culca | spăla | trezi | ști | dormi |
| --- | --- | --- | --- | --- | --- | --- |
| eu | mă | culc | spăl | trezesc | știu | dorm |
| tu | te | culci | speli | trezești | știi | dormi |
| el/ea | se | culcă | spală | trezește | știe | doarme |
| noi | ne | culcăm | spălăm | trezim | știm | dormim |
| voi | vă | culcați | spălați | treziți | știți | dormiți |
| ei/ele | se | culcă | spală | trezesc | știu | dorm |

`nu` and sentence-level `și` support `eu nu mă culc` and `mă spăl și mă culc`.
ASCII aliases include `ma culc`, `ne spalam`, and `stiu`; see `romanian.elx`.
To add a reflexive verb, assign its six forms to the existing `rv...` types and
provide a world relation. The clitic entries can be reused.

Dictionary references: [culca](https://dexonline.ro/definitie/culca),
[spăla](https://dexonline.ro/definitie/sp%C4%83la),
[trezi](https://dexonline.ro/definitie/trezi),
[ști](https://dexonline.ro/definitie/%C8%99ti).

## World and limits

Fixed referents are: `eu` Ana, `tu`/`el` Mihai, `ea` Ioana, `noi`/`ele` Ana/Ioana,
`voi` Mihai/Radu, and `ei` Ioana/Radu. Omitted third-person subjects use Ioana
(singular) or Ioana/Radu (plural), without discourse resolution.

## Assistance

OpenAI ChatGPT generated and revised the documentation, and tests, assisted with the interface, and ran validation.
