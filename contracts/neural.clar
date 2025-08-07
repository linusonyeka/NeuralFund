;; NeuralFund: AI-Powered Decentralized Venture Platform Smart Contract

(define-constant PLATFORM-ADMIN tx-sender)
(define-constant ERR-ACCESS-DENIED (err u100))
(define-constant ERR-BALANCE-INSUFFICIENT (err u101))
(define-constant ERR-VENTURE-NOT-FOUND (err u102))
(define-constant ERR-FUNDING-ROUND-CLOSED (err u103))
(define-constant ERR-MILESTONE-VALIDATED (err u104))
(define-constant ERR-INVALID-MILESTONE-ID (err u105))
(define-constant ERR-NO-WITHDRAWAL-RIGHTS (err u106))
(define-constant ERR-ALREADY-WITHDRAWN (err u107))
(define-constant ERR-VENTURE-SUCCESSFUL (err u108))
(define-constant ERR-INVALID-PARAMETERS (err u109))
(define-constant ERR-MILESTONES-INCOMPLETE (err u110))

;; Venture structure
(define-map neural-ventures
  { venture-id: uint }
  {
    founder: principal,
    project-name: (string-utf8 100),
    vision-statement: (string-utf8 500),
    funding-goal: uint,
    capital-raised: uint,
    launch-deadline: uint,
    is-live: bool,
    is-finalized: bool,
    development-phases: (list 5 { phase-description: (string-utf8 200), funding-required: uint, phase-validated: bool })
  }
)

;; Investment tracking with withdrawal status
(define-map neural-investments 
  { venture-id: uint, investor: principal } 
  { 
    investment-amount: uint,
    funds-withdrawn: bool 
  }
)

;; Unique venture ID counter
(define-data-var next-venture-id uint u0)

;; Helper function to check if all development phases are validated
(define-read-only (all-phases-validated? (development-phases (list 5 { phase-description: (string-utf8 200), funding-required: uint, phase-validated: bool })))
  (is-eq (len (filter is-phase-validated development-phases)) (len development-phases))
)

;; Helper function to check if a development phase is validated
(define-read-only (is-phase-validated (phase { phase-description: (string-utf8 200), funding-required: uint, phase-validated: bool }))
  (get phase-validated phase)
)

;; Launch a new AI venture
(define-public (launch-neural-venture 
  (project-name (string-utf8 100))
  (vision-statement (string-utf8 500))
  (funding-goal uint)
  (launch-deadline uint)
  (development-phases (list 5 { phase-description: (string-utf8 200), funding-required: uint }))
)
  (let 
    (
      (venture-id (var-get next-venture-id))
      (total-phase-funding (fold + (map get-phase-funding development-phases) u0))
    )
    ;; Validate inputs
    (asserts! (> (len project-name) u0) ERR-INVALID-PARAMETERS)
    (asserts! (> (len vision-statement) u0) ERR-INVALID-PARAMETERS)
    (asserts! (> funding-goal u0) ERR-INVALID-PARAMETERS)
    (asserts! (> launch-deadline block-height) ERR-INVALID-PARAMETERS)
    (asserts! (>= funding-goal total-phase-funding) ERR-BALANCE-INSUFFICIENT)
    
    ;; Create venture entry
    (map-set neural-ventures 
      { venture-id: venture-id }
      {
        founder: tx-sender,
        project-name: project-name,
        vision-statement: vision-statement,
        funding-goal: funding-goal,
        capital-raised: u0,
        launch-deadline: launch-deadline,
        is-live: true,
        is-finalized: false,
        development-phases: (map prepare-development-phase development-phases)
      }
    )
    
    ;; Increment venture ID
    (var-set next-venture-id (+ venture-id u1))
    
    ;; Return venture ID
    (ok venture-id)
  )
)

;; Helper function to get phase funding requirement
(define-read-only (get-phase-funding (phase { phase-description: (string-utf8 200), funding-required: uint }))
  (get funding-required phase)
)

;; Helper function to prepare development phase
(define-read-only (prepare-development-phase (phase { phase-description: (string-utf8 200), funding-required: uint }))
  { phase-description: (get phase-description phase), funding-required: (get funding-required phase), phase-validated: false }
)

;; Get development phase by index
(define-private (get-phase-by-index 
  (venture-phases (list 5 { phase-description: (string-utf8 200), funding-required: uint, phase-validated: bool })) 
  (phase-index uint)
)
  (element-at venture-phases phase-index)
)

;; Update development phase in list
(define-private (update-phase-list 
  (development-phases (list 5 { phase-description: (string-utf8 200), funding-required: uint, phase-validated: bool })) 
  (phase-index uint)
  (updated-phase { phase-description: (string-utf8 200), funding-required: uint, phase-validated: bool })
)
  (let
    (
      (prefix (unwrap! (slice? development-phases u0 phase-index) development-phases))
      (suffix (unwrap! (slice? development-phases (+ phase-index u1) (len development-phases)) development-phases))
    )
    (unwrap-panic 
      (as-max-len? 
        (concat
          prefix
          (unwrap-panic 
            (as-max-len? 
              (concat 
                (list updated-phase)
                suffix
              )
              u5
            )
          )
        )
        u5
      )
    )
  )
)

;; Check if venture is eligible for fund withdrawals
(define-read-only (is-withdrawal-eligible (venture-id uint))
  (match (map-get? neural-ventures { venture-id: venture-id })
    venture (and 
      (>= block-height (get launch-deadline venture))
      (< (get capital-raised venture) (get funding-goal venture))
      (get is-live venture)
    )
    false
  )
)

;; Invest in a neural venture
(define-public (neural-invest (venture-id uint) (stx-amount uint))
  (let 
    (
      (venture (unwrap! (map-get? neural-ventures { venture-id: venture-id }) ERR-VENTURE-NOT-FOUND))
      (current-investment (default-to { investment-amount: u0, funds-withdrawn: false } 
        (map-get? neural-investments { venture-id: venture-id, investor: tx-sender })))
    )
    ;; Validate inputs
    (asserts! (> venture-id u0) ERR-INVALID-PARAMETERS)
    (asserts! (> stx-amount u0) ERR-INVALID-PARAMETERS)
    
    ;; Validate venture is live and within deadline
    (asserts! (get is-live venture) ERR-FUNDING-ROUND-CLOSED)
    (asserts! (< block-height (get launch-deadline venture)) ERR-FUNDING-ROUND-CLOSED)
    
    ;; Update investments
    (map-set neural-investments 
      { venture-id: venture-id, investor: tx-sender }
      { investment-amount: (+ (get investment-amount current-investment) stx-amount), funds-withdrawn: false }
    )
    
    ;; Update venture capital raised
    (map-set neural-ventures 
      { venture-id: venture-id }
      (merge venture { capital-raised: (+ (get capital-raised venture) stx-amount) })
    )
    
    (ok true)
  )
)

;; Withdraw funds from failed venture
(define-public (withdraw-investment (venture-id uint))
  (let
    (
      (venture (unwrap! (map-get? neural-ventures { venture-id: venture-id }) ERR-VENTURE-NOT-FOUND))
      (investment (unwrap! (map-get? neural-investments { venture-id: venture-id, investor: tx-sender }) 
        ERR-NO-WITHDRAWAL-RIGHTS))
    )
    ;; Validate input
    (asserts! (> venture-id u0) ERR-INVALID-PARAMETERS)
    
    ;; Check withdrawal eligibility
    (asserts! (is-withdrawal-eligible venture-id) ERR-VENTURE-SUCCESSFUL)
    (asserts! (not (get funds-withdrawn investment)) ERR-ALREADY-WITHDRAWN)
    
    ;; Process withdrawal
    (try! (stx-transfer? (get investment-amount investment) tx-sender PLATFORM-ADMIN))
    
    ;; Mark investment as withdrawn
    (map-set neural-investments
      { venture-id: venture-id, investor: tx-sender }
      (merge investment { funds-withdrawn: true })
    )
    
    (ok true)
  )
)

;; Close failed venture and enable withdrawals
(define-public (close-failed-venture (venture-id uint))
  (let
    (
      (venture (unwrap! (map-get? neural-ventures { venture-id: venture-id }) ERR-VENTURE-NOT-FOUND))
    )
    ;; Validate input
    (asserts! (> venture-id u0) ERR-INVALID-PARAMETERS)
    
    ;; Verify venture has failed
    (asserts! (>= block-height (get launch-deadline venture)) ERR-FUNDING-ROUND-CLOSED)
    (asserts! (< (get capital-raised venture) (get funding-goal venture)) ERR-VENTURE-SUCCESSFUL)
    (asserts! (get is-live venture) ERR-FUNDING-ROUND-CLOSED)
    
    ;; Update venture status
    (map-set neural-ventures
      { venture-id: venture-id }
      (merge venture { is-live: false })
    )
    
    (ok true)
  )
)

;; Validate development phase
(define-public (validate-phase (venture-id uint) (phase-index uint))
  (let 
    (
      (venture (unwrap! (map-get? neural-ventures { venture-id: venture-id }) ERR-VENTURE-NOT-FOUND))
      (development-phases (get development-phases venture))
      (phase-opt (get-phase-by-index development-phases phase-index))
      (phase (unwrap! phase-opt ERR-INVALID-MILESTONE-ID))
    )
    ;; Validate inputs
    (asserts! (> venture-id u0) ERR-INVALID-PARAMETERS)
    (asserts! (< phase-index (len development-phases)) ERR-INVALID-PARAMETERS)
    
    ;; Only venture founder can validate phases
    (asserts! (is-eq tx-sender (get founder venture)) ERR-ACCESS-DENIED)
    (asserts! (not (get phase-validated phase)) ERR-MILESTONE-VALIDATED)
    
    ;; Update phase validation
    (map-set neural-ventures 
      { venture-id: venture-id }
      (merge venture { development-phases: (update-phase-list development-phases phase-index (merge phase { phase-validated: true })) })
    )
    
    (ok true)
  )
)

;; Finalize successful venture
(define-public (finalize-venture (venture-id uint))
  (let
    (
      (venture (unwrap! (map-get? neural-ventures { venture-id: venture-id }) ERR-VENTURE-NOT-FOUND))
    )
    ;; Validate inputs
    (asserts! (> venture-id u0) ERR-INVALID-PARAMETERS)
    
    ;; Only venture founder can finalize
    (asserts! (is-eq tx-sender (get founder venture)) ERR-ACCESS-DENIED)
    
    ;; Check if venture is live
    (asserts! (get is-live venture) ERR-FUNDING-ROUND-CLOSED)
    
    ;; Check if all development phases are validated
    (asserts! (all-phases-validated? (get development-phases venture)) ERR-MILESTONES-INCOMPLETE)
    
    ;; Update venture status
    (map-set neural-ventures
      { venture-id: venture-id }
      (merge venture 
        { 
          is-live: false,
          is-finalized: true
        }
      )
    )
    
    (ok true)
  )
)