/* FIȘIER TRADUS ȘI VERIFICAT ÎN LIMBA ROMÂNĂ */

# Discussion Questions — Introduction to Operating Systems

> Course 01 | Socratic questions for deeper engagement

---

## Foundational Understanding

1. **The Invisible Layer**
   
   You use your phone for hours daily, yet you never directly interact with the operating system. Why is this "invisibility" actually a feature, not a bug? What would computing look like if applications had to manage hardware directly?

2. **The Conductor Metaphor**
   
   We compared the OS to an orchestra conductor. Where does this metaphor break down? (Hint: think about what happens when the conductor makes a mistake versus when the OS crashes.)

---

## Architecture Trade-offs

3. **Monolithic vs Microkernel Debate**
   
   Linux uses a monolithic kernel and dominates the server market. Minix uses a microkernel and is considered more theoretically elegant. If microkernels are "better designed," why hasn't the industry adopted them more widely? What does this tell us about the relationship between theory and practice in systems design?

4. **The Hybrid Compromise**
   
   Windows NT and macOS chose hybrid architectures. Is this genuine engineering wisdom or simply "design by committee"? Can you think of other engineering domains where hybrid solutions dominate?

---

## Historical Context

5. **Batch Processing Then and Now**
   
   In the 1950s, batch processing increased CPU utilisation from ~30% to over 90%. Modern cloud platforms like AWS Batch and Kubernetes Jobs use similar concepts. What fundamental problem are both solving? Why hasn't this problem disappeared despite 70 years of hardware advancement?

6. **UNIX's Lasting Influence**
   
   UNIX was created in 1969 to run a game ("Space Travel"). Today, its descendants (Linux, macOS, Android, iOS) run on billions of devices. What design decisions from 1969 proved so durable? What assumptions from that era have become limitations?

---

## Design Thinking

7. **Embedded Systems Constraints**
   
   You are designing an OS for a pacemaker. Would you choose a monolithic kernel, microkernel, or hybrid? Justify your answer considering: real-time requirements, fault tolerance, power consumption and certification requirements.

8. **The Container Revolution**
   
   Docker containers are sometimes called "lightweight VMs," but this is technically incorrect. Based on what you learned about OS architecture, what do containers actually share with the host OS? What do they isolate?

---

## Practical Observation

9. **Process Explosion**
   
   Run `ps aux | wc -l` on your system. You might see 200+ processes on a "idle" desktop. Where do all these processes come from? Is this a sign of inefficiency or good design?

10. **The /proc Filesystem**
    
    Linux exposes kernel information through `/proc` as if it were a filesystem. Why did the designers choose this approach instead of dedicated system calls? What are the advantages and disadvantages?

---

## Synthesis

11. **Predicting the Future**
    
    Looking at the historical timeline (batch → time-sharing → personal → mobile → cloud → edge), what do you think the next major OS paradigm will be? What hardware or societal changes might drive it?

12. **The Abstraction Cost**
    
    Every abstraction has a cost. The OS abstracts hardware, which adds overhead. When might you want to bypass the OS and access hardware directly? (Hint: think about high-frequency trading, game engines, scientific computing.)

---

## For Advanced Discussion

13. **Formal Verification**
    
    The seL4 microkernel is formally verified—mathematically proven to be free of certain bugs. Why don't we formally verify Linux? Is it a matter of resources, or something more fundamental?

14. **Security vs Usability**
    
    Early UNIX systems were designed for trusted users in academic environments. Modern OSes must handle malicious users and software. How has this shift affected OS design? Give specific examples.

---

*Course 01 | Operating Systems | ASE Bucharest - CSIE | 2025-2026*
