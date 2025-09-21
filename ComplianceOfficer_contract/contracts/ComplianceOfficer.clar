
;; title: ComplianceOfficer
;; version: 1.0.0
;; summary: Address reputation system for regulatory compliance officer effectiveness scoring
;; description: This contract manages compliance officer reputation scores and provides
;;              a decentralized system for tracking regulatory compliance effectiveness.

;; traits
;;

;; token definitions
;;

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-score (err u102))
(define-constant err-officer-exists (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-invalid-address (err u105))

;; Scoring constants
(define-constant min-score u0)
(define-constant max-score u100)
(define-constant initial-score u50)

;; data vars
(define-data-var contract-paused bool false)
(define-data-var total-officers uint u0)

;; data maps
;; Main officer data structure
(define-map compliance-officers
  { officer-address: principal }
  {
    score: uint,
    total-assessments: uint,
    last-updated: uint,
    status: (string-ascii 20),
    registered-by: principal,
    registration-block: uint
  }
)

;; Assessment history tracking
(define-map assessment-history
  { officer-address: principal, assessment-id: uint }
  {
    score-change: int,
    assessor: principal,
    block-height: uint,
    reason: (string-ascii 100)
  }
)

;; Track assessment counts per officer
(define-map officer-assessment-count
  { officer-address: principal }
  { count: uint }
)

;; Authorized assessors (can update scores)
(define-map authorized-assessors
  { assessor: principal }
  { authorized: bool, added-by: principal, added-at: uint }
)

;; public functions

;; Register a new compliance officer
(define-public (register-officer (officer principal))
  (begin
    (asserts! (not (get-contract-paused)) (err u200))
    (asserts! (is-authorized-assessor tx-sender) err-unauthorized)
    (asserts! (is-none (map-get? compliance-officers { officer-address: officer })) err-officer-exists)

    (map-set compliance-officers
      { officer-address: officer }
      {
        score: initial-score,
        total-assessments: u0,
        last-updated: block-height,
        status: "active",
        registered-by: tx-sender,
        registration-block: block-height
      }
    )

    (var-set total-officers (+ (var-get total-officers) u1))
    (ok true)
  )
)

;; Update an officer's compliance score
(define-public (update-score (officer principal) (new-score uint) (reason (string-ascii 100)))
  (let (
    (current-officer (unwrap! (map-get? compliance-officers { officer-address: officer }) err-not-found))
    (current-count (default-to u0 (get count (map-get? officer-assessment-count { officer-address: officer }))))
  )
    (asserts! (not (get-contract-paused)) (err u200))
    (asserts! (is-authorized-assessor tx-sender) err-unauthorized)
    (asserts! (and (>= new-score min-score) (<= new-score max-score)) err-invalid-score)

    ;; Update officer record
    (map-set compliance-officers
      { officer-address: officer }
      (merge current-officer {
        score: new-score,
        total-assessments: (+ (get total-assessments current-officer) u1),
        last-updated: block-height
      })
    )

    ;; Record assessment history
    (map-set assessment-history
      { officer-address: officer, assessment-id: current-count }
      {
        score-change: (- (to-int new-score) (to-int (get score current-officer))),
        assessor: tx-sender,
        block-height: block-height,
        reason: reason
      }
    )

    ;; Update assessment count
    (map-set officer-assessment-count
      { officer-address: officer }
      { count: (+ current-count u1) }
    )

    (ok true)
  )
)

;; Add authorized assessor (only contract owner)
(define-public (add-assessor (assessor principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-assessors
      { assessor: assessor }
      { authorized: true, added-by: tx-sender, added-at: block-height }
    )
    (ok true)
  )
)

;; Remove authorized assessor (only contract owner)
(define-public (remove-assessor (assessor principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-delete authorized-assessors { assessor: assessor })
    (ok true)
  )
)

;; Update officer status
(define-public (update-officer-status (officer principal) (new-status (string-ascii 20)))
  (let (
    (current-officer (unwrap! (map-get? compliance-officers { officer-address: officer }) err-not-found))
  )
    (asserts! (not (get-contract-paused)) (err u200))
    (asserts! (is-authorized-assessor tx-sender) err-unauthorized)

    (map-set compliance-officers
      { officer-address: officer }
      (merge current-officer {
        status: new-status,
        last-updated: block-height
      })
    )
    (ok true)
  )
)

;; Emergency pause (only contract owner)
(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused true)
    (ok true)
  )
)

;; Resume contract (only contract owner)
(define-public (resume-contract)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused false)
    (ok true)
  )
)

;; read only functions

;; Get officer information
(define-read-only (get-officer-info (officer principal))
  (map-get? compliance-officers { officer-address: officer })
)

;; Get officer score
(define-read-only (get-officer-score (officer principal))
  (match (map-get? compliance-officers { officer-address: officer })
    officer-data (ok (get score officer-data))
    err-not-found
  )
)

;; Get officer reputation level based on score
(define-read-only (get-reputation-level (officer principal))
  (match (get-officer-score officer)
    score (ok (if (>= score u90)
                  "excellent"
                  (if (>= score u75)
                      "good"
                      (if (>= score u60)
                          "satisfactory"
                          (if (>= score u40)
                              "poor"
                              "critical")))))
    err err-not-found
  )
)

;; Check if address is an authorized assessor
(define-read-only (is-authorized-assessor (assessor principal))
  (default-to false (get authorized (map-get? authorized-assessors { assessor: assessor })))
)

;; Get contract pause status
(define-read-only (get-contract-paused)
  (var-get contract-paused)
)

;; Get total number of registered officers
(define-read-only (get-total-officers)
  (var-get total-officers)
)

;; Get assessment history for an officer
(define-read-only (get-assessment-history (officer principal) (assessment-id uint))
  (map-get? assessment-history { officer-address: officer, assessment-id: assessment-id })
)

;; Get officer assessment count
(define-read-only (get-officer-assessment-count (officer principal))
  (default-to u0 (get count (map-get? officer-assessment-count { officer-address: officer })))
)

;; Check if officer exists
(define-read-only (is-registered-officer (officer principal))
  (is-some (map-get? compliance-officers { officer-address: officer }))
)

;; Get contract owner
(define-read-only (get-contract-owner)
  contract-owner
)

;; Calculate average score across all officers (simplified version)
(define-read-only (get-average-score-indicator)
  ;; This is a simplified indicator - in a real implementation you might want
  ;; to iterate through all officers, but Clarity doesn't have iteration
  ;; This returns a basic health indicator
  (if (> (var-get total-officers) u0)
    (ok "active")
    (ok "no-officers")
  )
)

;; private functions

;; Initialize contract with owner as first assessor
(begin
  (map-set authorized-assessors
    { assessor: contract-owner }
    { authorized: true, added-by: contract-owner, added-at: block-height }
  )
)
