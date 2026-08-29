# Driver notes

This run repeats Opt-05 without changing the template commit, installed Skill, driver prompt, post-apply checkpoint, model, reasoning effort, or database engine. It uses a complete fresh project copy, a fresh Agent session, and a fresh local MySQL database.

The observable result is performant and functionally clean: implement took 555s, the first Action check passed with zero diagnostics, source finalization succeeded, and the implementation Gate completed. Compared with the first candidate run, stage time improved by 14.0%, outer time by 7.4%, and input tokens by 2.8%; these values satisfy the predefined ±15% timing threshold.

The execution protocol did not reproduce. `project source prepare` returned its 172KB implementation packet only through stdout. Unlike the first Agent, this Agent did not recreate the packet as a local retained file. It then issued 13 commands that queried `backend/model` or generated Go package documentation, contrary to the frozen prompt. No focused `action context` call was made, but the fallback queries invalidate the intended packet-only mechanism.

The run is retained as stability evidence but is not eligible to replace or strengthen the baseline. The next repair should make the CLI atomically persist the packet and return a bounded path/hash/summary receipt, removing reliance on Agent behavior.
