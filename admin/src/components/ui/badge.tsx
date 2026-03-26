import type { HTMLAttributes, ReactNode } from "react";

interface BadgeProps extends HTMLAttributes<HTMLSpanElement> {
	variant?: "cyan" | "amber" | "red" | "green";
	children: ReactNode;
}

export function Badge({
	variant = "cyan",
	children,
	className = "",
	...props
}: BadgeProps) {
	const variants = {
		cyan: "bg-cyan/15 text-cyan",
		amber: "bg-amber/15 text-amber",
		red: "bg-red/15 text-red",
		green: "bg-green/15 text-green",
	};

	return (
		<span
			className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${variants[variant]} ${className}`}
			{...props}
		>
			{children}
		</span>
	);
}
