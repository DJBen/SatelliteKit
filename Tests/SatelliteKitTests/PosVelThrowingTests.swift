/* ╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
 ║ PosVelThrowingTests.swift                                                                        ║
 ║                                                                                                  ║
 ║ Created by Gavin Eadie on Sep12/24   ...  Copyright 2024 Ramsay Consulting. All rights reserved. ║
 ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝ */

// swiftlint statement_position

import Foundation
@testable import SatelliteKit
import Testing

struct PosVelThrowingTests {
    @Test func SatPosition() {
        let sat = Satellite(
            "ISS (ZARYA)",
            "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
            "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577"
        )

        do {
            _ = try sat.position(minsAfterEpoch: 1_000_000_000.0)
            _ = try sat.velocity(minsAfterEpoch: 1_000_000_000.0)

            _ = try sat.position(julianDays: 1_000_000_000.0)
            _ = try sat.velocity(julianDays: 1_000_000_000.0)
        } catch {
            print(error)
        }
    }
}
